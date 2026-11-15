/// 방문 기록을 만든 결과 (회원가입·방명록 작성 응답이 같음)
class CheckInResult {
  const CheckInResult({
    required this.logId,
    required this.pcForm,
    required this.singForm,
    required this.pingForm,
  });

  final int logId; // 만들어진 방문 기록 번호
  final bool pcForm; // 컴퓨터 신청서를 써야 하는지
  final bool singForm; // 노래방 신청서를 써야 하는지
  final bool pingForm; // 탁구 신청서를 써야 하는지
}
