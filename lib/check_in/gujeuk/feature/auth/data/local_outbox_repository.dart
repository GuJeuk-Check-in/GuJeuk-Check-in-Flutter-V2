import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/storage/hive_setup.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_record.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_repository.dart';
import 'package:hive_ce/hive_ce.dart';

/// 암호화 키를 보관하는 곳. 앱 데이터 밖의 안전한 저장소에 둡니다.
abstract interface class OutboxKeyStore {
  Future<List<int>?> read();

  Future<void> write(List<int> key);
}

class SecureOutboxKeyStore implements OutboxKeyStore {
  static const _keyName = 'gujeuk_outbox_key';
  static const _storage = FlutterSecureStorage();

  const SecureOutboxKeyStore();

  @override
  Future<List<int>?> read() async {
    final encoded = await _storage.read(key: _keyName);
    return encoded == null ? null : base64Decode(encoded);
  }

  @override
  Future<void> write(List<int> key) =>
      _storage.write(key: _keyName, value: base64Encode(key));
}

/// 접수를 암호화 Hive 박스에 저장합니다. 박스는 처음 쓸 때 열고, 실패하면 다음에 다시 엽니다.
/// 값에 개인정보가 들어가고 Hive는 키를 암호화하지 않으므로, 키에는 `clientRecordId`만 씁니다.
class LocalOutboxRepository implements OutboxRepository {
  static const _boxName = 'gujeuk_outbox';

  final OutboxKeyStore _keys;
  final Future<void> Function() _init;

  LocalOutboxRepository({
    this._keys = const SecureOutboxKeyStore(),
    this._init = ensureHiveInitialized,
  });

  Future<Box<String>>? _box;

  Future<Box<String>> _opened() {
    return _box ??= _open().catchError((Object error) {
      _box = null;
      throw error;
    });
  }

  Future<Box<String>> _open() async {
    await _init();
    var key = await _keys.read();
    if (key == null) {
      // 키를 잃어버리면 남은 큐를 읽을 수 없으므로 비우고 새로 시작합니다.
      if (await Hive.boxExists(_boxName)) {
        debugPrint('outbox: 암호화 키가 없어 저장된 큐를 비웁니다.');
        await Hive.deleteBoxFromDisk(_boxName);
      }
      key = Hive.generateSecureKey();
      await _keys.write(key);
    }
    return Hive.openBox<String>(_boxName, encryptionCipher: HiveAesCipher(key));
  }

  @override
  Future<void> save(OutboxRecord record) async {
    final box = await _opened();
    await box.put(record.clientRecordId, record.encode());
    // 키오스크는 전원이 그냥 꺼질 수 있어 디스크에 내려간 뒤에 끝냅니다.
    await box.flush();
  }

  @override
  Future<List<OutboxRecord>> all() async {
    final box = await _opened();
    final records = <OutboxRecord>[];
    for (final entry in box.toMap().entries) {
      try {
        records.add(OutboxRecord.decode(entry.value));
      } catch (error) {
        // 한 건 때문에 나머지 재전송까지 막히지 않게 건너뜁니다. 값에는 개인정보가 있어 찍지 않습니다.
        debugPrint(
          'outbox: 읽을 수 없는 건을 건너뜀 ${entry.key} (${error.runtimeType})',
        );
      }
    }
    return records;
  }

  @override
  Future<void> delete(String clientRecordId) async {
    final box = await _opened();
    await box.delete(clientRecordId);
    await box.flush();
  }

  @override
  Future<void> deleteUnreadable() async {
    final box = await _opened();
    final unreadable = [
      for (final entry in box.toMap().entries)
        if (!_isReadable(entry.value)) entry.key,
    ];
    if (unreadable.isEmpty) return;
    debugPrint('outbox: 읽을 수 없는 건을 삭제 $unreadable');
    await box.deleteAll(unreadable);
    await box.flush();
  }

  bool _isReadable(String value) {
    try {
      OutboxRecord.decode(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  return LocalOutboxRepository();
});
