import 'package:dio/dio.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 서버의 방문 목적과 시설 예약. 409 말고는 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteReservationRepository implements ReservationRepository {
  final ApiClient _client;

  const RemoteReservationRepository(this._client);

  /// 새 API `/purpose/all/with-sub`을 먼저 부르고, 서버가 거절하거나 모양이 다르면 `/purpose/all`로 받습니다.
  /// 서버에 새 API가 배포되기 전에도 설치하자마자 목록을 받기 위해서입니다.
  /// 응답이 아예 없으면 `/purpose/all`도 닿지 않으므로 다시 부르지 않고 그대로 던집니다.
  // TODO: 운영 서버에 /purpose/all/with-sub이 배포되고 안정되면 대체 경로를 지웁니다.
  @override
  Future<List<VisitPurpose>> fetchVisitPurposes() async {
    try {
      return await _fetchPurposesWithSub();
    } on DioException catch (e) {
      if (e.response == null) rethrow;
    } on FormatException {
      // 명세와 다른 모양이면 예전 API로 받습니다.
    }
    return _fetchAllPurposes();
  }

  /// `GET /purpose/all/with-sub`. 모든 기관의 목적이 걸러지지 않고 `purposeIndex` 순으로
  /// `purposes` 안에 감싸져 옵니다. id는 `purposeId`로 옵니다.
  /// 하위 목적(`subPurposes`)은 아직 고르는 화면이 없어 담지 않습니다.
  Future<List<VisitPurpose>> _fetchPurposesWithSub() async {
    final response = await _client.dio.get<Object>('/purpose/all/with-sub');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('/purpose/all/with-sub 응답이 객체가 아닙니다');
    }
    final purposes = data['purposes'];
    if (purposes is! List<dynamic>) {
      throw const FormatException('/purpose/all/with-sub에 purposes가 없습니다');
    }
    return [
      for (final json in purposes)
        if (json case {'purposeId': final int id, 'purpose': final String name})
          VisitPurpose(id: id, purpose: name)
        else
          throw const FormatException('/purpose/all/with-sub의 목적 모양이 다릅니다'),
    ];
  }

  /// `GET /purpose/all`. 모든 기관의 목적이 걸러지지 않고 `purposeIndex` 순으로 옵니다.
  Future<List<VisitPurpose>> _fetchAllPurposes() async {
    final response = await _client.dio.get<List<dynamic>>('/purpose/all');
    return response.data!
        .map((json) => VisitPurpose.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// `GET /user/reservation/purpose`. 목록은 `purposes` 안에 감싸져 옵니다.
  /// 모든 목적이 `reservationStatus`(`RESERVATION` | `NONE` | `SUB_INCLUDE`)와 함께 오므로
  /// `RESERVATION`인 것만 담습니다. 값이 없으면 예전처럼 예약이 필요하다고 봅니다.
  /// `NONE`과 `SUB_INCLUDE`(하위 목록이 있는 목적)는 아직 시간 없이 바로 이용합니다.
  @override
  Future<List<VisitPurpose>> fetchReservablePurposes() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/user/reservation/purpose',
    );
    return (response.data!['purposes'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where(
          (json) =>
              (json['reservationStatus'] as String? ?? 'RESERVATION') ==
              'RESERVATION',
        )
        .map(VisitPurpose.fromJson)
        .toList();
  }

  /// `GET /user/reservation?purpose=`. 예약된 칸을 뺀 시간이 `times` 안에 감싸져 옵니다.
  /// 이미 지난 시간도 들어 있으므로 지난 칸은 화면에서 따로 막습니다.
  @override
  Future<List<String>> fetchAvailableTimes(String purpose) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/user/reservation',
      queryParameters: {'purpose': purpose},
    );
    return (response.data!['times'] as List<dynamic>).cast<String>();
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
      if (conflictMessageOf(e) == '같은 이름의 회원이 있습니다.') {
        throw const DuplicateNameException();
      }
      rethrow;
    }
  }

  /// 예약 칸이 찼다는 409. 가입하면서 예약할 때도 같은 응답이 옵니다.
  static bool isSlotTaken(DioException e) =>
      conflictMessageOf(e) == '이미 예약된 시간입니다.';
}
