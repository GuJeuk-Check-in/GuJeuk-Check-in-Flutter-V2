/// 서버의 이용대장 하나 (시설 항목)
class Purpose {
  const Purpose({required this.id, required this.name});

  final int id; // 신청서·방명록을 보낼 때 쓰는 번호
  final String name; // 예: 노래방
}

abstract class PurposeRepository {
  /// 이용대장 전체
  Future<List<Purpose>> fetchAll();
}
