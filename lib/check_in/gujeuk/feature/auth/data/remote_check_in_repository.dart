import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/server_date_format.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/check_in_repository.dart';

/// 서버의 방문 기록. 400, 404, 409, 500은 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteCheckInRepository implements CheckInRepository {
  final ApiClient _client;

  const RemoteCheckInRepository(this._client);

  /// `POST /user/check-in`. `visitTime`은 확인 버튼을 누른 지금 시각입니다.
  @override
  Future<void> checkIn({
    required int userId,
    required String purpose,
    required int maleCount,
    required int femaleCount,
  }) async {
    await _client.dio.post<void>(
      '/user/check-in',
      data: {
        'userId': userId,
        'maleCount': maleCount,
        'femaleCount': femaleCount,
        'purpose': purpose,
        'visitTime': ServerDateFormat.dateTime(DateTime.now()),
      },
    );
  }
}

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return RemoteCheckInRepository(ref.watch(apiClientProvider));
});
