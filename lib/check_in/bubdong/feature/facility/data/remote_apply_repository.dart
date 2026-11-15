import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/apply_repository.dart';

/// 서버로 신청서 보내기. 400·409 같은 에러는 DioException 그대로 위로 올라감
class RemoteApplyRepository implements ApplyRepository {
  final BubdongApiClient _client;

  const RemoteApplyRepository(this._client);

  /// `POST /check-in/pc` (성공하면 204, 본문 없음)
  @override
  Future<void> applyComputer({
    required int logId,
    required int seat,
    required String usePurpose,
  }) async {
    await _client.dio.post<void>(
      '/check-in/pc',
      data: {'logId': logId, 'seat': seat, 'usePurpose': usePurpose},
    );
  }
}
