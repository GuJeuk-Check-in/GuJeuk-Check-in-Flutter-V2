/// `GET /user/reservation` 한 줄. 오늘 이미 예약된 시설과 시작 시간입니다.
class ReservedSlot {
  /// [ReservationPurpose.purpose]와 같은 문자열로 내려옵니다.
  final String purpose;

  /// `HH:mm`. 서버는 `10:30:00`처럼 초까지 주므로 잘라서 담습니다.
  final String startTime;

  const ReservedSlot({required this.purpose, required this.startTime});

  factory ReservedSlot.fromJson(Map<String, dynamic> json) {
    return ReservedSlot(
      purpose: json['purpose'] as String,
      startTime: (json['startTime'] as String).substring(0, 5),
    );
  }
}
