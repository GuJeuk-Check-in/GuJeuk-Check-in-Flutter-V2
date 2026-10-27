class VisitPurpose {
  final int id;

  /// 예) `친친마루(게임, 독서 등)`
  final String purpose;

  const VisitPurpose({required this.id, required this.purpose});

  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'] as int,
      purpose: json['purpose'] as String,
    );
  }
}
