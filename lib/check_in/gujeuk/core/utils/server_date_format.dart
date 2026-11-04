/// 서버가 받는 날짜와 시각 문자열. 시간대 표시 없이 기기 시각 그대로 보냅니다.
abstract final class ServerDateFormat {
  /// `2008-05-04`
  static String date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${_two(value.month)}-${_two(value.day)}';

  /// `2026-01-01T14:30:00`
  static String dateTime(DateTime value) =>
      '${date(value)}T${_two(value.hour)}:${_two(value.minute)}:${_two(value.second)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
