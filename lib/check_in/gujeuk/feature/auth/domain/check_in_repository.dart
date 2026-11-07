/// 다시 온 친구의 방문 기록. 실패하면 예외를 던집니다.
abstract interface class CheckInRepository {
  /// 예약이 필요 없는 목적을 골랐을 때 보냅니다.
  /// [clientRecordId]가 같으면 다시 보내도 서버에 한 번만 남습니다.
  Future<void> checkIn({
    required int userId,
    required String purpose,
    required int maleCount,
    required int femaleCount,
    required DateTime visitTime,
    required String clientRecordId,
  });
}
