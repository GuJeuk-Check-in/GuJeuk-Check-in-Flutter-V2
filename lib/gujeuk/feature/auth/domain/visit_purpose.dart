/// 서버의 `reservationStatus`. 목적을 고르면 무엇을 해야 하는지 정합니다.
enum PurposeReservationStatus {
  /// 시간을 골라 예약합니다.
  reservation('RESERVATION'),

  /// 시간 없이 바로 이용합니다.
  none('NONE'),

  /// 하위 목적을 하나 더 고릅니다. 예약은 하위 단위로만 할 수 있습니다.
  subInclude('SUB_INCLUDE'),

  /// 앱이 모르는 값. 예약이 필요한 곳이 예약 없이 접수되지 않게 고를 수 없게 둡니다.
  unknown('UNKNOWN');

  final String serverValue;

  const PurposeReservationStatus(this.serverValue);

  static PurposeReservationStatus parse(String? value) => values.firstWhere(
    (status) => status.serverValue == value,
    orElse: () => unknown,
  );
}

/// `SUB_INCLUDE` 목적 아래의 하위 목적. 상위가 다르면 이름이 겹칠 수 있어 [id]로 구분합니다.
class SubPurpose {
  final int id;
  final String name;

  /// 고르면 시간도 골라 예약해야 하는지. 서버의 `subPurposeReservation`입니다.
  final bool needsReservation;

  const SubPurpose({
    required this.id,
    required this.name,
    required this.needsReservation,
  });

  /// 이름에 적힌 정원(`최대 4명`). 없으면 null입니다.
  int? get maxPeople => maxPeopleIn(name);

  Map<String, Object> toJson() => {
    'subPurposeId': id,
    'subPurpose': name,
    'subPurposeReservation': needsReservation,
  };

  factory SubPurpose.fromJson(Map<String, dynamic> json) {
    return SubPurpose(
      id: json['subPurposeId'] as int,
      name: json['subPurpose'] as String,
      needsReservation: json['subPurposeReservation'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SubPurpose &&
      other.id == id &&
      other.name == name &&
      other.needsReservation == needsReservation;

  @override
  int get hashCode => Object.hash(id, name, needsReservation);
}

/// 예약 시간 조회와 예약을 보내는 단위. 하위를 고르지 않았으면 [subPurposeId]가 null입니다.
/// [purpose]는 예전 서버가 이름으로만 찾을 때를 위해 함께 보냅니다.
typedef ReservationUnit = ({int purposeId, String purpose, int? subPurposeId});

final _maxPeoplePattern = RegExp(r'최대\s*(\d+)명');

/// 이름에 적힌 정원(`최대 4명`). API에 인원 필드가 없어 이름에서 읽습니다.
int? maxPeopleIn(String name) {
  final match = _maxPeoplePattern.firstMatch(name);
  return match == null ? null : int.parse(match.group(1)!);
}

class VisitPurpose {
  final int id;
  final String purpose;
  final PurposeReservationStatus reservationStatus;

  /// [PurposeReservationStatus.subInclude]일 때 고를 하위 목적. 서버 순서 그대로입니다.
  final List<SubPurpose> subPurposes;

  const VisitPurpose({
    required this.id,
    required this.purpose,
    this.reservationStatus = PurposeReservationStatus.none,
    this.subPurposes = const [],
  });

  /// 이름에 적힌 정원(`최대 4명`). 적혀 있지 않으면 null이고, 인원 제한이 없다고 봅니다.
  int? get maxPeople => maxPeopleIn(purpose);

  /// 카드로 골라도 되는지. 모르는 상태와 하위가 하나도 없는 `SUB_INCLUDE`는 고를 수 없습니다.
  bool get isSelectable => switch (reservationStatus) {
    PurposeReservationStatus.reservation ||
    PurposeReservationStatus.none => true,
    PurposeReservationStatus.subInclude => subPurposes.isNotEmpty,
    PurposeReservationStatus.unknown => false,
  };

  /// 고른 뒤 하위 목적을 하나 더 골라야 하는지.
  bool get needsSubPurpose =>
      reservationStatus == PurposeReservationStatus.subInclude;

  Map<String, Object> toJson() => {
    'id': id,
    'purpose': purpose,
    'reservationStatus': reservationStatus.serverValue,
    'subPurposes': [for (final sub in subPurposes) sub.toJson()],
  };

  /// 저장본과 `/user/reservation/purpose` 응답을 읽습니다.
  /// 상태가 없으면 [PurposeReservationStatus.unknown]이라 고를 수 없습니다.
  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'] as int,
      purpose: json['purpose'] as String,
      reservationStatus: PurposeReservationStatus.parse(
        json['reservationStatus'] as String?,
      ),
      subPurposes: [
        for (final sub in json['subPurposes'] as List<dynamic>? ?? const [])
          SubPurpose.fromJson(sub as Map<String, dynamic>),
      ],
    );
  }
}
