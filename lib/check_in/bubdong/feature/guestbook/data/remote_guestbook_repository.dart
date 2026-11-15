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

  /// `GET /log/{logId}`
  @override
  Future<GuestbookDetail> fetchDetail(int logId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/log/$logId',
    );
    final json = response.data!;
    return GuestbookDetail(
      name: json['name'] as String,
      forms: [
        for (final item in json['purpose'] as List)
          ?_toFormStatus(item as Map<String, dynamic>),
      ],
      organRemainTime: json['organRemainTime'] as int,
      purposeRemainTime: json['purposeRemainTime'] as int,
    );
  }

  /// 서버 신청서 하나 → 앱의 ApplyFormStatus (모르는 값이면 null로 뺌)
  ApplyFormStatus? _toFormStatus(Map<String, dynamic> json) {
    final form = switch (json['purposeName']) {
      'pcForm' => ApplyForm.pc,
      'pingForm' => ApplyForm.ping,
      'singForm' => ApplyForm.sing,
      _ => null,
    };
    final state = switch (json['purposeState']) {
      'none' => ApplyFormState.none,
      'pending' => ApplyFormState.pending,
      'success' => ApplyFormState.success,
      _ => null,
    };
    if (form == null || state == null) return null;
    return ApplyFormStatus(
      form: form,
      selected: json['purposeSelect'] as bool,
      state: state,
    );
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
