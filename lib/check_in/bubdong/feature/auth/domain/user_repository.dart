/// 전화번호로 회원을 찾을 수 있다는 약속
abstract class UserRepository {
  /// 등록된 회원이면 userId, 없으면 null
  Future<int?> findUserId(String phone);
}