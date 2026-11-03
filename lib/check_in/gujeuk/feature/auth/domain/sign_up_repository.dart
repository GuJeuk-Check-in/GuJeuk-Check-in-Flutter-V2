import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';

/// 처음 온 친구의 회원가입. 실패하면 예외를 던집니다.
abstract interface class SignUpRepository {
  /// 가입과 함께 이번 방문 기록이 남습니다.
  /// 예약이 필요한 시설이면 [reservationTime](`09:30`)을 넘겨 한 번에 예약합니다.
  /// 그 칸이 그사이 찼으면 가입까지 취소되고 [SlotTakenException]을 던집니다.
  /// [phone]은 하이픈 없이 숫자만(`01012345678`) 넘깁니다.
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
  });
}

enum Gender {
  man('MAN'),
  woman('WOMAN');

  /// 서버가 받는 값.
  final String serverValue;

  const Gender(this.serverValue);
}
