import 'package:dio/dio.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 서버의 방문 목적과 시설 예약.
/// 409와 목적이 바뀌었다는 400·404 말고는 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteReservationRepository implements ReservationRepository {
  final ApiClient _client;

  const RemoteReservationRepository(this._client);

  /// `GET /purpose/all/with-sub`. 모든 기관의 목적이 걸러지지 않고 `purposeIndex` 순으로
  /// `purposes` 안에 감싸져 옵니다. id는 `purposeId`로 옵니다.
  /// 모양이 명세와 다르면 [FormatException]을 던져, 저장해 둔 목록을 쓰게 합니다.
  @override
  Future<List<VisitPurpose>> fetchVisitPurposes() async {
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
        if (json case {
          'purposeId': final int id,
          'purpose': final String name,
          'reservationStatus': final String status,
          'subPurposes': final List<dynamic> subs,
        })
          VisitPurpose(
            id: id,
            purpose: name,
            reservationStatus: PurposeReservationStatus.parse(status),
            subPurposes: [for (final sub in subs) _subPurposeOf(sub)],
          )
        else
          throw const FormatException('/purpose/all/with-sub의 목적 모양이 다릅니다'),
    ];
  }

  static SubPurpose _subPurposeOf(Object? json) => switch (json) {
    {
      'subPurposeId': final int id,
      'subPurpose': final String name,
      'subPurposeReservation': final bool needsReservation,
    } =>
      SubPurpose(id: id, name: name, needsReservation: needsReservation),
    _ => throw const FormatException('/purpose/all/with-sub의 하위 목적 모양이 다릅니다'),
  };

  /// `GET /user/reservation/purpose`. 목록은 `purposes` 안에 감싸져 옵니다.
  /// 모든 목적이 `reservationStatus`(`RESERVATION` | `NONE` | `SUB_INCLUDE`)와 함께 오므로
  /// `RESERVATION`인 것만 담습니다. 값이 없으면 예전처럼 예약이 필요하다고 봅니다.
  /// `SUB_INCLUDE`(하위 목록이 있는 목적)는 하위 단위로만 예약할 수 있어 여기에 담지 않고,
  /// 화면에서 고를 수 없게 막습니다.
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

  /// `GET /user/reservation?purposeId=&subPurposeId=`. 예약된 칸을 뺀 시간이 `times` 안에 감싸져 옵니다.
  /// 이미 지난 시간도 들어 있으므로 지난 칸은 화면에서 따로 막습니다.
  @override
  Future<List<String>> fetchAvailableTimes(ReservationUnit unit) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _client.dio.get<Map<String, dynamic>>(
        '/user/reservation',
        queryParameters: {
          'purposeId': unit.purposeId,
          'subPurposeId': ?unit.subPurposeId,
        },
      );
    } on DioException catch (e) {
      if (isPurposeChanged(e)) throw const PurposeChangedException();
      rethrow;
    }
    return (response.data!['times'] as List<dynamic>).cast<String>();
  }

  /// `POST /user/reservation`. 전화번호가 있으면 서버는 이름 대신 번호로 회원을 찾습니다.
  @override
  Future<void> reserve({
    required String name,
    String? phone,
    required ReservationUnit unit,
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
          'purpose': unit.purpose,
          'purposeId': unit.purposeId,
          'subPurposeId': ?unit.subPurposeId,
          'startTime': startTime,
        },
      );
    } on DioException catch (e) {
      if (isSlotTaken(e)) throw const SlotTakenException();
      if (isPurposeChanged(e)) throw const PurposeChangedException();
      if (conflictMessageOf(e) == '같은 이름의 회원이 있습니다.') {
        throw const DuplicateNameException();
      }
      rethrow;
    }
  }

  /// 예약 칸이 찼다는 409. 가입하면서 예약할 때도 같은 응답이 옵니다.
  static bool isSlotTaken(DioException e) =>
      conflictMessageOf(e) == '이미 예약된 시간입니다.';

  /// 고른 목적이나 하위 목적이 그사이 지워졌거나 예약할 수 없게 바뀌었다는 400·404.
  /// 가입하면서 예약할 때와 예약 시간을 조회할 때도 같은 응답이 옵니다.
  static bool isPurposeChanged(DioException e) =>
      _purposeChangedMessages.contains(rejectionMessageOf(e));

  static const _purposeChangedMessages = {
    '예약할 수 없는 방문 목적입니다.',
    '존재하지 않는 방문목적입니다.',
    '존재하지 않는 하위 방문목적입니다.',
  };
}
