/// 법동에서 고를 수 있는 이용대장 (Figma 이용대장 선택 화면 순서)
enum Facility {
  internet('인터넷', needsApplication: true),
  tableTennis('탁구', needsApplication: true),
  boardGame('보드게임'),
  rest('휴식'),
  bangka('방카'),
  karaoke('노래방', needsApplication: true),
  youthCouncil('청운위'),
  club('동아리'),
  workStudy('근로장학생'),
  other('기타(노인일자리)');

  const Facility(this.label, {this.needsApplication = false});

  /// 화면에 보이는 이름
  final String label;

  /// 고른 뒤 신청서를 써야 하는지 (카드에 "신청서 작성" 표시)
  final bool needsApplication;
}
