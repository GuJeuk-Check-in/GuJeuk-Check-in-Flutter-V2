/// 서버 방명록 한 줄 (이용대장은 id로 옴)
class GuestbookLog {
  const GuestbookLog({
    required this.id,
    required this.name,
    required this.purposeIds,
    required this.organRemainTime,
  });

  final int id;
  final String name;
  final List<int> purposeIds; // GET /purpose의 id
  final int organRemainTime; // 분 (화면에는 이용한 시간으로 보여줌)
}

/// 신청서 종류 (서버 pcForm / pingForm / singForm)
enum ApplyForm { pc, ping, sing }

/// 신청서 상태 (서버 none / pending / success)
enum ApplyFormState { none, pending, success }

/// 방명록 상세의 신청서 하나
class ApplyFormStatus {
  const ApplyFormStatus({
    required this.form,
    required this.selected,
    required this.state,
  });

  final ApplyForm form;
  final bool selected; // 골랐는지
  final ApplyFormState state;
}

/// 방명록 상세 (GET /log/{logId})
class GuestbookDetail {
  const GuestbookDetail({
    required this.name,
    required this.forms,
    required this.organRemainTime,
    required this.purposeRemainTime,
  });

  final String name;
  final List<ApplyFormStatus> forms; // 신청서 3종 상태
  final int organRemainTime; // 분
  final int purposeRemainTime; // 분, 화면의 "이용한 시간"
}

abstract class GuestbookRepository {
  /// 방명록 한 페이지 (page는 0부터, 한 페이지 30개)
  Future<List<GuestbookLog>> fetchPage({int page = 0});

  /// 방명록 전체 (한 페이지가 가득 차 있으면 다음 페이지를 이어서 요청)
  Future<List<GuestbookLog>> fetchAll();

  /// 방명록 하나의 자세한 내용
  Future<GuestbookDetail> fetchDetail(int logId);

  /// 방명록의 이용대장을 바꿔 저장 (purposeIds: 바꾼 뒤 전체 id), 바뀐 신청서 상태를 돌려줌
  Future<List<ApplyFormStatus>> updatePurposes(int logId, List<int> purposeIds);
}
