/// 서버가 받는 날짜와 시각 문자열. 시간대 표시 없이 한국 시각으로 보냅니다.
abstract final class ServerDateFormat {
  /// 한국은 서머타임이 없어 늘 UTC+9입니다.
  static const _koreaOffset = Duration(hours: 9);

  /// [instant] 순간의 한국 벽시계 시각. 연·월·일·시·분을 읽는 데만 씁니다.
  /// 기기 시간대가 UTC 등으로 잘못 설정돼 있어도 같은 값이 나옵니다.
  static DateTime koreaWallClock(DateTime instant) =>
      instant.toUtc().add(_koreaOffset);

  /// `2008-05-04`. 생년월일처럼 순간이 아닌 날짜라 시간대를 옮기지 않습니다.
  static String date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${_two(value.month)}-${_two(value.day)}';

  /// `2026-01-01T14:30:00`. 방문 시각 같은 순간을 한국 시각으로 적습니다.
  static String dateTime(DateTime value) {
    final korea = koreaWallClock(value);
    return '${date(korea)}T${_two(korea.hour)}:${_two(korea.minute)}:${_two(korea.second)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
