/// 다시 온 친구의 방문 기록. 실패하면 예외를 던집니다.
abstract interface class CheckInRepository {
  /// 예약이 필요 없는 목적을 골랐을 때 보냅니다. 방문 시각은 보내는 지금입니다.
  Future<void> checkIn({
    required int userId,
    required String purpose,
    required int maleCount,
    required int femaleCount,
  });
}
