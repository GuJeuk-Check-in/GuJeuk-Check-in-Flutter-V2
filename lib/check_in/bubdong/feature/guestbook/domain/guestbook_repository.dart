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

abstract class GuestbookRepository {
  /// 방명록 한 페이지 (page는 0부터, 한 페이지 30개)
  Future<List<GuestbookLog>> fetchPage({int page = 0});
}
