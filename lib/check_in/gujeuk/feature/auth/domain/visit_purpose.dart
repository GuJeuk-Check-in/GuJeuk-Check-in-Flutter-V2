class VisitPurpose {
  final int id;

  /// 예) `친친마루(게임, 독서 등)`
  final String purpose;

  const VisitPurpose({required this.id, required this.purpose});

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
    );
  }
}
