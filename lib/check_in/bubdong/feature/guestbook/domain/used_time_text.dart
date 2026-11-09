/// 이용 시간 글자 (방명록 카드, 이용대장 선택 화면이 같이 씀)
/// 30분 → '30분', 60분 → '1시간', 80분 → '1시간 20분'
extension UsedTimeText on Duration {
  String get usedTimeText {
    final hours = inHours;
    final minutes = inMinutes % 60;
    if (hours == 0) return '$minutes분'; // 1시간 미만
    if (minutes == 0) return '$hours시간'; // 딱 나누어떨어짐
    return '$hours시간 $minutes분';
  }
}
