import 'package:dio/dio.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/ha_repository.dart';

/// 서버의 HA API. 명세는 201이지만 서버 코드는 200을 돌려주므로 Dio처럼 2xx를 모두 성공으로 봅니다.
class RemoteHaRepository implements HaRepository {
  final ApiClient _client;

  const RemoteHaRepository(this._client);

  /// `GET /common/health/ready`. 서버나 DB가 내려가 있으면 503이 옵니다.
  @override
  Future<bool> isReady() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/common/health/ready',
      );
      final data = response.data;
      return data?['status'] == 'UP' && data?['db'] == 'UP';
    } on DioException {
      return false;
    }
  }

  /// `POST /user/ha-log`.
  @override
  Future<void> sendLog(String body) async {
    await _client.dio.post<void>('/user/ha-log', data: body);
  }

  /// `POST /user/ha-sign-up`.
  @override
  Future<void> sendSignUp(String body) async {
    await _client.dio.post<void>('/user/ha-sign-up', data: body);
  }
}
