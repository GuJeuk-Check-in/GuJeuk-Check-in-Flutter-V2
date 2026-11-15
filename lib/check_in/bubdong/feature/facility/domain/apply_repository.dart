/// 이용대장 신청서를 보낼 수 있다는 약속
abstract class ApplyRepository {
  /// 컴퓨터 신청서 (logId: 회원가입·방명록 작성 때 받은 방문 기록 번호)
  Future<void> applyComputer({
    required int logId,
    required int seat,
    required String usePurpose,
  });
}
