import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/local_outbox_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_ha_repository.dart';
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

  final OutboxRepository _outbox;
  final HaRepository _ha;
  final DateTime Function() _now;

  OutboxSyncService(this._outbox, this._ha, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  bool _isRunning = false;

  /// 앱이 전송 중에 꺼졌던 건을 다시 보낼 수 있게 되돌립니다. 앱을 시작할 때 부릅니다.
  Future<void> recover() async {
    final retryAt = _now().add(outboxFirstRetryDelay);
    for (final record in await _outbox.all()) {
      if (record.status == OutboxStatus.sending) {
        await _outbox.save(record.markPending(retryAt));
      }
    }
  }

  /// 보낼 때가 된 건을 큐가 빌 때까지 보냅니다. 이미 돌고 있으면 그대로 둡니다.
  Future<void> run() async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await _deleteExpired();
      final now = _now();
      final due = (await _outbox.all()).where((r) => _isDue(r, now)).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final record in due) {
        // 서버가 응답하지 않으면 다음 건도 실패할 테니 이번 회차는 멈춥니다.
        if (!await _send(record)) break;
      }
    } finally {
      _isRunning = false;
    }
  }

  bool _isDue(OutboxRecord record, DateTime now) {
    if (record.status == OutboxStatus.sending) return false;
    final retryAt = record.nextRetryAt;
    return retryAt != null && !retryAt.isAfter(now);
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
      if (isRetryableFailure(error)) {
        final attempts = record.attempts + 1;
        await _outbox.save(
          record.markRetry(now.add(retryDelayOf(attempts)), now),
        );
        return false;
      }
      await _outbox.save(record.markPermanentlyFailed(now));
      _logFailed(record, error);
      return true;
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
  /// 실패 건은 실패한 때부터, 재시도 중인 건은 접수한 때부터 셉니다.
  Future<void> _deleteExpired() async {
    final limit = _now().subtract(_retention);
    for (final record in await _outbox.all()) {
      if (record.status == OutboxStatus.sending) continue;
      final since = record.isPermanentlyFailed
          ? record.failedAt ?? record.createdAt
          : record.createdAt;
      if (since.isAfter(limit)) continue;
      debugPrint(
        'outbox: 보관 기간이 지나 삭제 ${record.clientRecordId} (${record.kind.name})',
      );
      await _outbox.delete(record.clientRecordId);
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
  );
});
