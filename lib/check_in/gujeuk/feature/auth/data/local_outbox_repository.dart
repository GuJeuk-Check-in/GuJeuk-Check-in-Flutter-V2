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
///
/// Hive는 파일이 손상된 지점 뒤를 버리므로 같은 내용을 예비 박스에도 저장해 두고, 열 때 서로 채웁니다.
/// 지운 건이 되살아나도 서버가 같은 ID를 걸러 주므로 예비 박스 쓰기는 실패해도 접수를 막지 않습니다.
class LocalOutboxRepository implements OutboxRepository {
  static const _boxName = 'gujeuk_outbox';
  static const _backupBoxName = 'gujeuk_outbox_backup';

  final OutboxKeyStore _keys;
  final Future<void> Function() _init;

  LocalOutboxRepository({
    this._keys = const SecureOutboxKeyStore(),
    this._init = ensureHiveInitialized,
  });

  Future<Box<String>>? _box;
  Box<String>? _backup;

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
      for (final name in [_boxName, _backupBoxName]) {
        if (await Hive.boxExists(name)) {
          debugPrint('outbox: 암호화 키가 없어 저장된 큐를 비웁니다. ($name)');
          await Hive.deleteBoxFromDisk(name);
        }
      }
      key = Hive.generateSecureKey();
      await _keys.write(key);
    }
    final cipher = HiveAesCipher(key);
    var backup = await _tryOpenBackup(cipher);
    final box = await _openMain(cipher, backup);
    // 본 박스가 열렸으니 키는 맞습니다. 그런데도 못 여는 예비 박스는 손상된 것이므로 새로 만듭니다.
    if (backup == null && box.isNotEmpty) {
      backup = await _rebuildBackup(cipher);
    }
    if (backup != null) await _link(box, backup);
    return box;
  }

  /// 첫 건이 손상된 박스와 키가 틀린 박스는 Hive가 똑같이 열지 못합니다.
  /// 예비 박스에 읽히는 건이 있으면 키가 맞다는 뜻이므로, 그때만 지우고 예비 박스로 되살립니다.
  Future<Box<String>> _openMain(
    HiveAesCipher cipher,
    Box<String>? backup,
  ) async {
    try {
      return await Hive.openBox<String>(_boxName, encryptionCipher: cipher);
    } catch (_) {
      if (backup == null || backup.isEmpty) rethrow;
      debugPrint('outbox: 손상된 박스를 예비 박스로 되살립니다.');
      await Hive.deleteBoxFromDisk(_boxName);
      return Hive.openBox<String>(_boxName, encryptionCipher: cipher);
    }
  }

  Future<Box<String>?> _tryOpenBackup(HiveAesCipher cipher) async {
    try {
      return await Hive.openBox<String>(
        _backupBoxName,
        encryptionCipher: cipher,
      );
    } catch (error) {
      debugPrint('outbox: 예비 박스 열기 실패 (${error.runtimeType})');
      return null;
    }
  }

  Future<Box<String>?> _rebuildBackup(HiveAesCipher cipher) async {
    try {
      await Hive.deleteBoxFromDisk(_backupBoxName);
    } catch (error) {
      debugPrint('outbox: 예비 박스 삭제 실패 (${error.runtimeType})');
      return null;
    }
    return _tryOpenBackup(cipher);
  }

  Future<void> _link(Box<String> box, Box<String> backup) async {
    try {
      await _fillMissing(box, backup);
      await _fillMissing(backup, box);
      _backup = backup;
    } catch (error) {
      debugPrint('outbox: 예비 박스 맞추기 실패 (${error.runtimeType})');
    }
  }

  Future<void> _fillMissing(Box<String> target, Box<String> source) async {
    final missing = {
      for (final entry in source.toMap().entries)
        if (!target.containsKey(entry.key)) entry.key: entry.value,
    };
    if (missing.isEmpty) return;
    debugPrint('outbox: ${target.name}에 없는 ${missing.length}건을 채웁니다.');
    await target.putAll(missing);
    await target.flush();
  }

  Future<void> _writeBackup(Future<void> Function(Box<String>) write) async {
    final backup = _backup;
    if (backup == null) return;
    try {
      await write(backup);
      await backup.flush();
    } catch (error) {
      debugPrint('outbox: 예비 박스 쓰기 실패 (${error.runtimeType})');
    }
  }

  @override
  Future<void> save(OutboxRecord record) async {
    final box = await _opened();
    final encoded = record.encode();
    await box.put(record.clientRecordId, encoded);
    // 키오스크는 전원이 그냥 꺼질 수 있어 디스크에 내려간 뒤에 끝냅니다.
    await box.flush();
    await _writeBackup((backup) => backup.put(record.clientRecordId, encoded));
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
    await _writeBackup((backup) => backup.delete(clientRecordId));
  }

  @override
  Future<void> deleteUnreadable() async {
    await _deleteUnreadableFrom(await _opened());
    await _writeBackup(_deleteUnreadableFrom);
  }

  Future<void> _deleteUnreadableFrom(Box<String> box) async {
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
