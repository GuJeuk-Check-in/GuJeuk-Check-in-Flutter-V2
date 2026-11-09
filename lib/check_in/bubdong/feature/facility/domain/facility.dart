/// 법동에서 고를 수 있는 이용대장 (Figma 이용대장 선택 화면 순서)
enum Facility {
  internet('인터넷', needsApplication: true),
  tableTennis('탁구', needsApplication: true, maxPeople: 4),
  boardGame('보드게임'),
  rest('휴식'),
  bangka('방카'),
  karaoke('노래방', needsApplication: true, maxPeople: 2),
  youthCouncil('청운위'),
  club('동아리'),
  workStudy('근로장학생', forChildren: false),
  other('기타(노인일자리)', forChildren: false);

  const Facility(
    this.label, {
    this.needsApplication = false,
    this.maxPeople,
    this.forChildren = true,
  });

  /// 화면에 보이는 이름
  final String label;

  /// 고른 뒤 신청서를 써야 하는지 (카드에 "신청서 작성" 표시)
  final bool needsApplication;

  /// 함께 이용할 수 있는 최대 인원 (인원을 적는 신청서만, 회의 결정: 노래방 2명)
  final int? maxPeople;

  /// 아이들도 고를 수 있는지 (근로장학생·기타는 어른만)
  final bool forChildren;

  /// 아이들 이용대장 8개 (Figma 아이들 흐름, 방명록 흐름도 같음)
  static final children = values.where((f) => f.forChildren).toList();

  /// 어른 이용대장 10개 (아이들 8개 + 근로장학생, 기타)
  static const adults = values;
}
