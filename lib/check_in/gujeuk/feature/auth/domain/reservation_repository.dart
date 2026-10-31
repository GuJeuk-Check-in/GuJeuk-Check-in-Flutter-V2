import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reserved_slot.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 방문 목적과 시설 예약 조회. 실패하면 예외를 던집니다.
abstract interface class ReservationRepository {
  /// 모든 방문 목적. 회원가입 카드를 이 목록으로 그립니다.
  Future<List<VisitPurpose>> fetchVisitPurposes();

  /// 예약이 필요한 시설만. 이 목적을 고르면 시간도 골라야 합니다.
  Future<List<VisitPurpose>> fetchReservablePurposes();

  /// 오늘 예약된 칸 목록. 모든 시설의 예약이 함께 옵니다.
  Future<List<ReservedSlot>> fetchReservedSlots();

  /// `POST /user/reservation`. 이미 가입한 친구만 씁니다. 새 친구는 가입하면서 예약합니다.
  /// [phone]은 같은 이름의 회원이 있을 때만, 하이픈 없이 숫자만(`01012345678`) 넘깁니다.
  /// 회원 확인용이 아니라 예약 문자를 받을 번호라 서버가 맞는지 따지지 않습니다.
  /// [startTime]은 `09:30`. 409는 [DuplicateNameException], [SlotTakenException]으로 나눠 던집니다.
  Future<void> reserve({
    required String name,
    String? phone,
    required String purpose,
    required String startTime,
    required int maleCount,
    required int femaleCount,
  });
}

/// 409 `같은 이름의 회원이 있습니다.` 전화번호를 받아 다시 요청해야 합니다.
class DuplicateNameException implements Exception {
  const DuplicateNameException();
}

/// 409 `이미 예약된 시간입니다.` 그사이 다른 친구가 같은 칸을 예약했습니다.
class SlotTakenException implements Exception {
  const SlotTakenException();
}
