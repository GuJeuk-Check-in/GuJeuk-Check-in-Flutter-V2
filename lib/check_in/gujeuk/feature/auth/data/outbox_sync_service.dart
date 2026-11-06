import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/server_clock.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/repository_providers.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/ha_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_record.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_repository.dart';

/// 방금 보낸 요청을 서버가 아직 처리 중일 수 있어 첫 재전송은 이만큼 기다립니다.
/// 같은 ID가 동시에 들어가면 서버 유니크 제약에 걸려 400으로 돌아옵니다.
const outboxFirstRetryDelay = Duration(seconds: 30);

/// 저장해 둔 접수를 오래된 순서로 HA API에 보냅니다.
class OutboxSyncService {
  static const _maxRetryDelay = Duration(minutes: 10);
  static const _retention = Duration(days: 7);

  /// 기기 시각이 잠깐 튄 것일 수 있어 만료된 뒤 이만큼 계속 만료 상태일 때만 지웁니다.
  static const _expiryGrace = Duration(hours: 1);

  final OutboxRepository _outbox;
  final HaRepository _ha;
  final DateTime Function() _now;
  final Duration Function() _uptime;

  OutboxSyncService(
    this._outbox,
    this._ha, {
    DateTime Function()? now,
    Duration Function()? uptime,
  }) : _now = now ?? DateTime.now,
       _uptime = uptime ?? monotonicUptime();

  bool _isRunning = false;

  /// 건별로 처음 만료 상태를 본 때. 앱을 재시작하면 처음부터 다시 셉니다.
  final _expiredSince = <String, Duration>{};

  /// 앱이 꺼지거나 저장에 실패해 전송 중으로 남은 건을 다시 보낼 수 있게 되돌립니다.
  /// 회차는 겹치지 않으므로 회차를 시작할 때 전송 중인 건은 모두 이렇게 남은 건입니다.
  Future<void> recover() async {
    final retryAt = _now().add(outboxFirstRetryDelay);
    for (final record in await _outbox.all()) {
      if (record.status == OutboxStatus.sending) {
        await _outbox.save(record.markPending(retryAt));
      }
    }
  }

  /// 보낼 때가 된 건을 큐가 빌 때까지 보냅니다. 이미 돌고 있으면 그대로 둡니다.
  Future<void> run() => _exclusive(() async {
    await _cleanUp();
    final now = _now();
    final due = (await _outbox.all()).where((r) => _isDue(r, now)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final record in due) {
      // 내용 문제가 아니면 다음 건도 실패할 테니 이번 회차는 멈춥니다.
      if (!await _send(record)) break;
    }
  });

  /// 서버가 내려가 있어도 개인정보가 보관 기간을 넘기지 않게 정리합니다.
  Future<void> cleanUp() => _exclusive(_cleanUp);

  Future<void> _exclusive(Future<void> Function() work) async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await work();
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _cleanUp() async {
    await recover();
    await _deleteExpired();
  }

  bool _isDue(OutboxRecord record, DateTime now) {
    if (record.status == OutboxStatus.sending) return false;
    if (_isExpired(record, now)) return false;
    final retryAt = record.nextRetryAt;
    if (retryAt == null) return false;
    // 최대 대기 시간보다 멀면 기기 시각이 과거로 돌아간 것이므로 기다리지 않습니다.
    return !retryAt.isAfter(now) || retryAt.difference(now) > _maxRetryDelay;
  }

  /// 실패 건은 실패한 때부터, 재시도 중인 건은 접수한 때부터 셉니다.
  bool _isExpired(OutboxRecord record, DateTime now) {
    final since = record.isPermanentlyFailed
        ? record.failedAt ?? record.createdAt
        : record.createdAt;
    return !since.isAfter(now.subtract(_retention));
  }

  /// 한 건을 보냅니다. 다음 건으로 넘어가도 되면 true입니다.
  Future<bool> _send(OutboxRecord record) async {
    await _outbox.save(record.markSending());
    try {
      await switch (record.kind) {
        OutboxKind.checkIn => _ha.sendLog(record.body),
        OutboxKind.signUp => _ha.sendSignUp(record.body),
      };
    } catch (error) {
      if (isDuplicateLog(error)) {
        await _outbox.delete(record.clientRecordId);
        return true;
      }
      final now = _now();
      // 앞선 요청이 아직 처리 중이어도 400이 오므로 첫 400은 한 번 더 확인합니다.
      final mayBeInFlight = isBadRequest(error) && record.attempts == 0;
      if (isContentRejection(error) && !mayBeInFlight) {
        await _outbox.save(record.markPermanentlyFailed(now));
        _logFailed(record, error);
        return true;
      }
      final attempts = record.attempts + 1;
      await _outbox.save(
        record.markRetry(now.add(retryDelayOf(attempts)), now),
      );
      return mayBeInFlight;
    }
    await _outbox.delete(record.clientRecordId);
    return true;
  }

  /// [attempts]번 실패한 건의 대기 시간. 30초부터 2배씩 늘고 10분을 넘지 않습니다.
  /// 시도 횟수가 커지면 정수 거듭제곱이 넘쳐 0이 되므로 지수에 상한을 둡니다.
  @visibleForTesting
  static Duration retryDelayOf(int attempts) {
    final seconds =
        outboxFirstRetryDelay.inSeconds << min(max(attempts - 1, 0), 6);
    return Duration(seconds: min(seconds, _maxRetryDelay.inSeconds));
  }

  /// 개인정보가 기기에 계속 남지 않게 정해진 기간이 지난 건을 지웁니다.
  Future<void> _deleteExpired() async {
    await _outbox.deleteUnreadable();
    final now = _now();
    final uptime = _uptime();
    for (final record in await _outbox.all()) {
      if (record.status == OutboxStatus.sending) continue;
      final id = record.clientRecordId;
      if (!_isExpired(record, now)) {
        _expiredSince.remove(id);
        continue;
      }
      final expiredSince = _expiredSince.putIfAbsent(id, () => uptime);
      if (uptime - expiredSince < _expiryGrace) continue;
      debugPrint(
        'outbox: 보관 기간이 지나 삭제 ${record.clientRecordId} (${record.kind.name})',
      );
      await _outbox.delete(id);
      _expiredSince.remove(id);
    }
  }

  /// 관리 화면이 없어 로그로만 남깁니다. 본문에는 개인정보가 있어 찍지 않습니다.
  void _logFailed(OutboxRecord record, Object error) {
    final failure = error is DioException
        ? error.response?.statusCode
        : error.runtimeType;
    debugPrint(
      'outbox: 전송 실패로 보관 ${record.clientRecordId} (${record.kind.name}, $failure)',
    );
  }
}

final outboxSyncServiceProvider = Provider<OutboxSyncService>((ref) {
  return OutboxSyncService(
    ref.watch(outboxRepositoryProvider),
    ref.watch(haRepositoryProvider),
    now: ref.watch(serverClockProvider).now,
  );
});
