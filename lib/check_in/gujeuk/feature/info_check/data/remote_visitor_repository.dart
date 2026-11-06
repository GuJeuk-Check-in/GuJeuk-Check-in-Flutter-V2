import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/domain/visitor_repository.dart';

/// 서버의 방문자 조회. 400, 500은 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteVisitorRepository implements VisitorRepository {
  final ApiClient _client;

  const RemoteVisitorRepository(this._client);

  /// `POST /user`. 없는 이름이면 `userExists`가 false이고 `userId`는 null로 옵니다.
  @override
  Future<int?> findUserId(String name) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/user',
      data: {'name': name},
    );
    return response.data!['userId'] as int?;
  }
}
