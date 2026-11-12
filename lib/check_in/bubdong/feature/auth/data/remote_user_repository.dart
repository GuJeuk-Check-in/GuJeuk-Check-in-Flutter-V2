import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/user_repository.dart';

class RemoteUserRepository implements UserRepository {
  final BubdongApiClient _client;

  const RemoteUserRepository(this._client);

  @override
  Future<int?> findUserId(String phone) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/check-in',
      queryParameters: {'phone': phone},
    );
    return response.data!['userId'] as int?;
  }
}