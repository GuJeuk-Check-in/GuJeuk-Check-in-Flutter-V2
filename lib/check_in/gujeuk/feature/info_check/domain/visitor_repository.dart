/// 방문자 조회. 실패하면 예외를 던집니다.
abstract interface class VisitorRepository {
  /// 이 이름으로 등록된 방문자의 id. 없으면 null입니다.
  /// 같은 이름이 여럿이면 서버가 돌아가며 한 명을 고릅니다. 방문 기록은 이 id로 남깁니다.
  Future<int?> findUserId(String name);
}
