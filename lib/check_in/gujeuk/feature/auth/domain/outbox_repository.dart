import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_record.dart';

/// 서버로 보내기 전에 접수를 담아 두는 기기 저장소. 실패하면 예외를 던집니다.
abstract interface class OutboxRepository {
  /// 기기에 완전히 기록된 뒤에 끝납니다. 같은 ID가 있으면 덮어씁니다.
  Future<void> save(OutboxRecord record);

  Future<List<OutboxRecord>> all();

  Future<void> delete(String clientRecordId);
}
