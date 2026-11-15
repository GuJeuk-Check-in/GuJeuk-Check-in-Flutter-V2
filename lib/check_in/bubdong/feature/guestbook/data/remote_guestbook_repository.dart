import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_repository.dart';

/// 서버의 방명록 조회. 400·500 같은 에러는 DioException 그대로 위로 올라감
class RemoteGuestbookRepository implements GuestbookRepository {
  final BubdongApiClient _client;

  const RemoteGuestbookRepository(this._client);

  static const _pageSize = 30; // 명세: 30개씩

  /// `GET /log?page=&size=`
  @override
  Future<List<GuestbookLog>> fetchPage({int page = 0}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/log',
      queryParameters: {'page': page, 'size': _pageSize},
    );
    return (response.data!['content'] as List)
        .map((item) => _toLog(item as Map<String, dynamic>))
        .toList();
  }

  /// 서버 방명록 하나 → 앱의 GuestbookLog
  GuestbookLog _toLog(Map<String, dynamic> json) {
    return GuestbookLog(
      id: json['id'] as int,
      name: json['name'] as String,
      purposeIds: (json['purpose'] as List).cast<int>(),
      organRemainTime: json['organRemainTime'] as int,
    );
  }
}
