/// 문화센터를 알게 된 경로
enum VisitRoute {
  friend('친구가 데려와서'),
  parent('부모님의 권유'),
  other('기타');

  const VisitRoute(this.label);

  /// 화면에 보이는 글자
  final String label;
}