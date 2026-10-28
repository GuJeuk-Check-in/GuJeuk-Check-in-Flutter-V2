/// 방문자 조회. 실패하면 예외를 던집니다.
abstract interface class VisitorRepository {
  /// 이 이름으로 등록된 방문자가 있는지. 동명이인은 구분하지 않습니다.
  Future<bool> exists(String name);
}
