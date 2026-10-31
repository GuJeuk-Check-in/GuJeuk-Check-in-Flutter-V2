class VisitPurpose {
  final int id;
  final String purpose;

  /// 지금 예약을 받는지. `GET /user/reservation/purpose`의 `reservationStatus`입니다.
  /// 다른 목록에는 이 값이 없어 받는 것으로 봅니다.
  final bool isReservationOpen;

  const VisitPurpose({
    required this.id,
    required this.purpose,
    this.isReservationOpen = true,
  });

  static final _maxPeoplePattern = RegExp(r'최대\s*(\d+)명');

  /// 이름에 적힌 정원(`최대 4명`). API에 인원 필드가 없어 이름에서 읽습니다.
  /// 적혀 있지 않으면 null이고, 인원 제한이 없다고 봅니다.
  int? get maxPeople {
    final match = _maxPeoplePattern.firstMatch(purpose);
    return match == null ? null : int.parse(match.group(1)!);
  }

  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'] as int,
      purpose: json['purpose'] as String,
      isReservationOpen: json['reservationStatus'] as bool? ?? true,
    );
  }
}
