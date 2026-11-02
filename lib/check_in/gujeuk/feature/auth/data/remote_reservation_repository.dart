import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reserved_slot.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 서버의 방문 목적과 시설 예약. 409 말고는 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteReservationRepository implements ReservationRepository {
  final ApiClient _client;

  const RemoteReservationRepository(this._client);

  /// `GET /purpose/all`. 모든 기관의 목적이 걸러지지 않고 `purposeIndex` 순으로 옵니다.
  @override
  Future<List<VisitPurpose>> fetchVisitPurposes() async {
    final response = await _client.dio.get<List<dynamic>>('/purpose/all');
    return response.data!
        .map((json) => VisitPurpose.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// `GET /user/reservation/purpose`. 목록은 `purposes` 안에 감싸져 옵니다.
  /// 모든 목적이 `reservationStatus`(예약이 필요한지)와 함께 오므로 true인 것만 담습니다.
  /// false인 목적은 시간 없이 바로 이용합니다.
  @override
  Future<List<VisitPurpose>> fetchReservablePurposes() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/user/reservation/purpose',
    );
    return (response.data!['purposes'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((json) => json['reservationStatus'] as bool? ?? true)
        .map(VisitPurpose.fromJson)
        .toList();
  }

  /// `GET /user/reservation`. 오늘 예약만 시설과 시작 시간으로 옵니다.
  @override
  Future<List<ReservedSlot>> fetchReservedSlots() async {
    final response = await _client.dio.get<List<dynamic>>('/user/reservation');
    return response.data!
        .map((json) => ReservedSlot.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// `POST /user/reservation`. 전화번호가 있으면 서버는 이름 대신 번호로 회원을 찾습니다.
  @override
  Future<void> reserve({
    required String name,
    String? phone,
    required String purpose,
    required String startTime,
    required int maleCount,
    required int femaleCount,
  }) async {
    try {
      await _client.dio.post<void>(
        '/user/reservation',
        data: {
          'name': name,
          if (phone != null) 'phone': PhoneNumberFormatter.format(phone),
          'maleCount': maleCount,
          'femaleCount': femaleCount,
          'purpose': purpose,
          'startTime': startTime,
        },
      );
    } on DioException catch (e) {
      if (isSlotTaken(e)) throw const SlotTakenException();
      if (_conflictMessage(e) == '같은 이름의 회원이 있습니다.') {
        throw const DuplicateNameException();
      }
      rethrow;
    }
  }

  /// 예약 칸이 찼다는 409. 가입하면서 예약할 때도 같은 응답이 옵니다.
  static bool isSlotTaken(DioException e) =>
      _conflictMessage(e) == '이미 예약된 시간입니다.';

  /// 409는 여러 이유가 같은 상태 코드로 오므로 `message`로 나눕니다.
  static String? _conflictMessage(DioException e) {
    final response = e.response;
    if (response?.statusCode != 409) return null;
    final data = response!.data;
    return data is Map<String, dynamic> ? data['message'] as String? : null;
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return RemoteReservationRepository(ref.watch(apiClientProvider));
});
