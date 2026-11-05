import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/storage/hive_setup.dart';
import 'package:hive_ce/hive_ce.dart';

/// 기기 시각이 바뀌어도 영향받지 않고 흐르는 시간. 기기를 재시작하면 처음부터 다시 셉니다.
Duration Function() monotonicUptime() {
  final stopwatch = Stopwatch()..start();
  return () => stopwatch.elapsed;
}

/// 다음 실행 때도 보정할 수 있게 저장해 두는 값.
typedef ClockState = ({int offsetMillis, int serverMillis});

/// 시각 보정값을 담아 두는 곳. 개인정보가 없어 암호화하지 않습니다.
abstract interface class ClockStore {
  Future<ClockState?> read();

  Future<void> write(ClockState state);
}

class HiveClockStore implements ClockStore {
  static const _boxName = 'gujeuk_clock';
  static const _offsetKey = 'offsetMillis';
  static const _serverKey = 'serverMillis';

  final Future<void> Function() _init;

  HiveClockStore({this._init = ensureHiveInitialized});

  Future<Box<int>> _opened() async {
    await _init();
    return Hive.openBox<int>(_boxName);
  }

  @override
  Future<ClockState?> read() async {
    final box = await _opened();
    final offset = box.get(_offsetKey);
    final server = box.get(_serverKey);
    if (offset == null || server == null) return null;
    return (offsetMillis: offset, serverMillis: server);
  }

  @override
  Future<void> write(ClockState state) async {
    final box = await _opened();
    await box.putAll({
      _offsetKey: state.offsetMillis,
      _serverKey: state.serverMillis,
    });
    await box.flush();
  }
}

/// 서버 시각으로 보정한 현재 시각. 방문 시각과 보관 기간은 이 시각을 씁니다.
///
/// 서버 응답이 올 때마다 기기 시각과의 차이를 저장해 두므로 장애 중에도 같은 차이로 보정합니다.
/// 보정한 시각이 마지막 서버 시각보다 과거면 기기 시각이 뒤로 간 것이므로 서버 시각부터 이어서 셉니다.
class ServerClock {
  /// 응답 지연과 초 단위 헤더 때문에 생기는 차이는 무시합니다.
  static const _tolerance = Duration(seconds: 2);

  /// 차이가 그대로여도 마지막 서버 시각이 너무 낡지 않게 이 간격으로 저장합니다.
  static const _saveInterval = Duration(minutes: 10);

  final ClockStore _store;
  final DateTime Function() _deviceNow;
  final Duration Function() _uptime;

  ServerClock(
    this._store, {
    DateTime Function()? deviceNow,
    Duration Function()? uptime,
  }) : _deviceNow = deviceNow ?? DateTime.now,
       _uptime = uptime ?? monotonicUptime();

  Duration _offset = Duration.zero;
  DateTime? _serverTime;
  Duration _serverTimeAt = Duration.zero;
  Duration? _savedAt;

  /// 앱을 시작할 때 저장해 둔 보정값을 읽습니다. 못 읽으면 기기 시각을 그대로 씁니다.
  Future<void> load() async {
    try {
      final state = await _store.read();
      if (state == null || _serverTime != null) return;
      _offset = Duration(milliseconds: state.offsetMillis);
      _serverTime = DateTime.fromMillisecondsSinceEpoch(state.serverMillis);
      _serverTimeAt = _uptime();
    } catch (error) {
      debugPrint('clock: 보정값 읽기 실패 (${error.runtimeType})');
    }
  }

  DateTime now() {
    final corrected = _deviceNow().add(_offset);
    final serverTime = _serverTime;
    if (serverTime == null || !corrected.isBefore(serverTime)) return corrected;
    return serverTime.add(_uptime() - _serverTimeAt);
  }

  /// 응답의 `Date` 헤더로 보정합니다. 없거나 읽을 수 없으면 그대로 둡니다.
  void syncWithDateHeader(String? header) {
    if (header == null) return;
    final DateTime serverTime;
    try {
      serverTime = HttpDate.parse(header).toLocal();
    } catch (_) {
      debugPrint('clock: Date 헤더를 읽을 수 없습니다.');
      return;
    }
    _sync(serverTime);
  }

  void _sync(DateTime serverTime) {
    final offset = serverTime.difference(_deviceNow());
    final hasMoved = (offset - _offset).abs() > _tolerance;
    if (hasMoved) _offset = offset;
    _serverTime = serverTime;
    _serverTimeAt = _uptime();
    final savedAt = _savedAt;
    if (hasMoved || savedAt == null || _uptime() - savedAt >= _saveInterval) {
      _savedAt = _uptime();
      unawaited(_save(serverTime));
    }
  }

  Future<void> _save(DateTime serverTime) async {
    try {
      await _store.write((
        offsetMillis: _offset.inMilliseconds,
        serverMillis: serverTime.millisecondsSinceEpoch,
      ));
    } catch (error) {
      debugPrint('clock: 보정값 저장 실패 (${error.runtimeType})');
    }
  }
}

final serverClockProvider = Provider<ServerClock>((ref) {
  return ServerClock(HiveClockStore());
});
