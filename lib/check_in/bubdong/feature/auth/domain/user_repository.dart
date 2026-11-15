import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/check_in_result.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/sign_up_request.dart';

/// 전화번호로 회원을 찾고, 새 회원을 등록할 수 있다는 약속
abstract class UserRepository {
  /// 등록된 회원이면 userId, 없으면 null
  Future<int?> findUserId(String phone);

  /// 회원가입 + 첫 방문 기록 (purposeIds: 고른 이용대장 id)
  Future<CheckInResult> signUp(SignUpRequest request, List<int> purposeIds);

  /// 다시 온 친구의 방명록 작성 (purposeIds: 고른 이용대장 id)
  Future<CheckInResult> checkIn(int userId, List<int> purposeIds);
}
