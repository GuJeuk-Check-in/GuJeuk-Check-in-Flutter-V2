import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/residence_repository.dart';

/// 서버의 거주지 목록. 500은 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteResidenceRepository implements ResidenceRepository {
  final ApiClient _client;

  const RemoteResidenceRepository(this._client);

  /// `GET /residence/all`. 모든 기관의 거주지가 걸러지지 않고 `residenceIndex` 순으로 옵니다.
  /// 응답의 `id`는 쓰는 곳이 없어 이름만 담습니다.
  @override
  Future<List<String>> fetchResidences() async {
    final response = await _client.dio.get<List<dynamic>>('/residence/all');
    return response.data!
        .map((json) => (json as Map<String, dynamic>)['residence'] as String)
        .toList();
  }
}

final residenceRepositoryProvider = Provider<ResidenceRepository>((ref) {
  return RemoteResidenceRepository(ref.watch(apiClientProvider));
});
