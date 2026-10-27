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
}
