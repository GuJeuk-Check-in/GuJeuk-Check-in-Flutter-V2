import 'package:hive_ce_flutter/hive_ce_flutter.dart';

Future<void>? _initialized;

/// Hive 저장 경로를 한 번만 잡습니다. 실패하면 다음 호출에서 다시 시도합니다.
Future<void> ensureHiveInitialized() {
  return _initialized ??= Hive.initFlutter().catchError((Object error) {
    _initialized = null;
    throw error;
  });
}
