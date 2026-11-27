import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 방문 목적과 시설 예약 조회. 실패하면 예외를 던집니다.
abstract interface class ReservationRepository {
  /// 모든 방문 목적. 회원가입 카드를 이 목록으로 그립니다.
  Future<List<VisitPurpose>> fetchVisitPurposes();

  /// 예약이 필요한 시설만. 이 목적을 고르면 시간도 골라야 합니다.
  Future<List<VisitPurpose>> fetchReservablePurposes();

  /// [unit]에서 아직 예약할 수 있는 시간(`HH:mm`).
  /// 예약할 수 없거나 없는 시설이면 [PurposeChangedException]을 던집니다.
  Future<List<String>> fetchAvailableTimes(ReservationUnit unit);

  /// `POST /user/reservation`. 이미 가입한 친구만 씁니다. 새 친구는 가입하면서 예약합니다.
  /// [phone]은 같은 이름의 회원이 있을 때만, 하이픈 없이 숫자만(`01012345678`) 넘깁니다.
  /// 회원 확인용이 아니라 예약 문자를 받을 번호라 서버가 맞는지 따지지 않습니다.
  /// [startTime]은 `09:30`. 409는 [DuplicateNameException], [SlotTakenException]으로 나눠 던집니다.
  /// 목적이 바뀌었으면 [PurposeChangedException]을 던집니다.
  Future<void> reserve({
    required String name,
    String? phone,
    required ReservationUnit unit,
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

/// 400 `예약할 수 없는 방문 목적입니다.` 또는 404 `존재하지 않는 방문목적입니다.`·`존재하지 않는 하위 방문목적입니다.`
/// 저장해 둔 목록을 쓰는 사이 관리자가 목적을 지웠거나 예약 방식을 바꿨습니다.
/// 목록을 다시 받아 목적을 새로 골라야 합니다.
class PurposeChangedException implements Exception {
  const PurposeChangedException();
}
