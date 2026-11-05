import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/option_cache.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/outbox_sync_service.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_ha_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/ha_repository.dart';

/// 서버 상태를 주기적으로 확인해, 받을 수 있을 때 큐를 보내고 복구되면 목록을 다시 받습니다.
class OutboxSyncController {
  static const _readyInterval = Duration(seconds: 60);
  static const _downInterval = Duration(seconds: 5);

  final HaRepository _ha;
  final OutboxSyncService _sync;
  final OptionsLoader _options;

  OutboxSyncController(this._ha, this._sync, this._options);

  Timer? _timer;
  bool _wasReady = false;
  bool _isDisposed = false;
  bool _isServerDown = false;
  bool _isRefreshingOptions = false;

  /// 지난번에 못 받은 목록이 있는지. 서버가 계속 정상이어도 다음 확인 때 다시 받습니다.
  bool _optionsStale = false;

  /// 마지막 확인에서 서버가 준비되지 않았는지. 아직 확인 전이면 false입니다.
  bool get isServerDown => _isServerDown;

  /// 앱을 시작할 때 한 번 부릅니다.
  Future<void> start() => _check();

  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
  }

  /// 목록을 받는 동안 큐 전송과 다음 확인이 밀리지 않게 기다리지 않고 부릅니다.
  Future<void> _refreshOptions() async {
    if (_isRefreshingOptions) return;
    _isRefreshingOptions = true;
    try {
      _optionsStale = !await _options.refresh();
    } finally {
      _isRefreshingOptions = false;
    }
  }

  Future<void> _check() async {
    var isReady = false;
    try {
      isReady = await _ha.isReady();
      _isServerDown = !isReady;
      if (isReady) {
        if (!_wasReady || _optionsStale) unawaited(_refreshOptions());
        await _sync.run();
      }
    } catch (error) {
      debugPrint('outbox: 재전송 실패 (${error.runtimeType})');
    }
    _wasReady = isReady;
    if (_isDisposed) return;
    _timer = Timer(isReady ? _readyInterval : _downInterval, _check);
  }
}

final outboxSyncControllerProvider = Provider<OutboxSyncController>((ref) {
  final controller = OutboxSyncController(
    ref.watch(haRepositoryProvider),
    ref.watch(outboxSyncServiceProvider),
    ref.watch(optionsLoaderProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
