import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_purpose.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reserved_slot.dart';

/// 시설 예약 조회. 실패하면 예외를 던집니다.
abstract interface class ReservationRepository {
  /// 예약이 필요한 시설 목록. 방문 목적 순서대로 옵니다.
  Future<List<ReservationPurpose>> fetchPurposes();

  /// 오늘 예약된 칸 목록. 모든 시설의 예약이 함께 옵니다.
  Future<List<ReservedSlot>> fetchReservedSlots();
}
