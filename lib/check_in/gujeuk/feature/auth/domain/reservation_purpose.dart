/// `GET /user/reservation/purpose` 한 줄. 예약이 필요한 시설(방문 목적)입니다.
class ReservationPurpose {
  final int id;

  /// 예) `친친마루(게임, 독서 등)`
  final String purpose;

  const ReservationPurpose({required this.id, required this.purpose});

  factory ReservationPurpose.fromJson(Map<String, dynamic> json) {
    return ReservationPurpose(
      id: json['id'] as int,
      purpose: json['purpose'] as String,
    );
  }
}
