import 'package:dio/dio.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_purpose.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reserved_slot.dart';

/// 실제 서버 호출. base URL은 넘겨받는 [Dio]에 설정해 두세요.
/// 500 응답은 dio가 [DioException]으로 던집니다.
class ReservationRepositoryImpl implements ReservationRepository {
  final Dio _dio;

  const ReservationRepositoryImpl(this._dio);

  @override
  Future<List<ReservationPurpose>> fetchPurposes() async {
    final response = await _dio.get<List<dynamic>>('/user/reservation/purpose');
    return response.data!
        .map((json) => ReservationPurpose.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ReservedSlot>> fetchReservedSlots() async {
    final response = await _dio.get<List<dynamic>>('/user/reservation');
    return response.data!
        .map((json) => ReservedSlot.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
