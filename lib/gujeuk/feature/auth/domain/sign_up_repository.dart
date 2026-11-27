import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/reservation_repository.dart';

/// 처음 온 친구의 회원가입. 실패하면 예외를 던집니다.
abstract interface class SignUpRepository {
  /// 가입과 함께 이번 방문 기록이 남습니다.
  /// 예약이 필요한 시설이면 [reservationTime](`09:30`)을 넘겨 한 번에 예약합니다.
  /// 그 칸이 그사이 찼으면 가입까지 취소되고 [SlotTakenException]을 던집니다.
  /// [purpose]는 상위 목적 이름이고, 하위 목적을 예약하면 [subPurposeId]를 함께 넘깁니다.
  /// [phone]은 하이픈 없이 숫자만(`01012345678`) 넘깁니다.
  /// 목적이 바뀌었으면 [PurposeChangedException]을, 거주지가 없어졌으면 [ResidenceChangedException]을 던집니다.
  Future<void> signUp({
    required String name,
    required Gender gender,
    required String phone,
    required DateTime birthDate,
    required String residence,
    required String purpose,
    required int maleCount,
    required int femaleCount,
    required DateTime visitTime,
    String? reservationTime,
    int? subPurposeId,
  });
}

/// 404 `존재하지 않는 거주지 입니다.` 저장해 둔 목록을 쓰는 사이 관리자가 거주지를 지웠거나 이름을 바꿨습니다.
/// 목록을 다시 받아 거주지를 새로 골라야 합니다.
class ResidenceChangedException implements Exception {
  const ResidenceChangedException();
}

enum Gender {
  man('MAN'),
  woman('WOMAN');

  /// 서버가 받는 값.
  final String serverValue;

  const Gender(this.serverValue);
}
