import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/purpose_repository.dart';

/// 서버의 이용대장 조회. 500 같은 에러는 DioException 그대로 위로 올라감
class RemotePurposeRepository implements PurposeRepository {
  final BubdongApiClient _client;

  const RemotePurposeRepository(this._client);

  /// `GET /purpose`
  @override
  Future<List<Purpose>> fetchAll() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/purpose');
    return (response.data!['purposes'] as List)
        .map((item) => _toPurpose(item as Map<String, dynamic>))
        .toList();
  }

  /// 서버 이용대장 하나 → 앱의 Purpose
  Purpose _toPurpose(Map<String, dynamic> json) {
    return Purpose(id: json['id'] as int, name: json['purposeName'] as String);
  }
}
