/// 서버의 `reservationStatus`. 목적을 고르면 무엇을 해야 하는지 정합니다.
enum PurposeReservationStatus {
  /// 시간을 골라 예약합니다.
  reservation('RESERVATION'),

  /// 시간 없이 바로 이용합니다.
  none('NONE'),

  /// 하위 목적 단위로만 예약할 수 있습니다. 하위를 고르는 화면이 없어 아직 고를 수 없습니다.
  subInclude('SUB_INCLUDE'),

  /// 앱이 모르는 값. 예약이 필요한 곳이 예약 없이 접수되지 않게 고를 수 없게 둡니다.
  unknown('UNKNOWN');

  final String serverValue;

  const PurposeReservationStatus(this.serverValue);

  static PurposeReservationStatus parse(String? value) => values.firstWhere(
    (status) => status.serverValue == value,
    orElse: () => unknown,
  );

  /// 지금 화면에서 카드로 골라도 되는지.
  bool get isSelectable => this == reservation || this == none;
}

class VisitPurpose {
  final int id;
  final String purpose;
  final PurposeReservationStatus reservationStatus;

  const VisitPurpose({
    required this.id,
    required this.purpose,
    this.reservationStatus = PurposeReservationStatus.none,
  });

  static final _maxPeoplePattern = RegExp(r'최대\s*(\d+)명');

  /// 이름에 적힌 정원(`최대 4명`). API에 인원 필드가 없어 이름에서 읽습니다.
  /// 적혀 있지 않으면 null이고, 인원 제한이 없다고 봅니다.
  int? get maxPeople {
    final match = _maxPeoplePattern.firstMatch(purpose);
    return match == null ? null : int.parse(match.group(1)!);
  }

  Map<String, Object> toJson() => {
    'id': id,
    'purpose': purpose,
    'reservationStatus': reservationStatus.serverValue,
  };

  /// 상태가 없으면 [PurposeReservationStatus.unknown]이라 고를 수 없습니다.
  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'] as int,
      purpose: json['purpose'] as String,
      reservationStatus: PurposeReservationStatus.parse(
        json['reservationStatus'] as String?,
      ),
    );
  }
}
