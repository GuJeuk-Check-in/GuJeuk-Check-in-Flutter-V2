import 'package:dio/dio.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/core/utils/server_date_format.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/reservation_repository.dart';

/// 서버의 방문 기록. 목적이 지워졌다는 404 말고는 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteCheckInRepository implements CheckInRepository {
  final ApiClient _client;

  const RemoteCheckInRepository(this._client);

  /// `POST /user/check-in`.
  @override
  Future<void> checkIn({
    required int userId,
    required String purpose,
    required int maleCount,
    required int femaleCount,
    required DateTime visitTime,
    required String clientRecordId,
  }) async {
    try {
      await _client.dio.post<void>(
        '/user/check-in',
        data: {
          'userId': userId,
          'maleCount': maleCount,
          'femaleCount': femaleCount,
          'purpose': purpose,
          'visitTime': ServerDateFormat.dateTime(visitTime),
          'clientRecordId': clientRecordId,
        },
      );
    } on DioException catch (e) {
      if (RemoteReservationRepository.isPurposeChanged(e)) {
        throw const PurposeChangedException();
      }
      rethrow;
    }
  }
}
