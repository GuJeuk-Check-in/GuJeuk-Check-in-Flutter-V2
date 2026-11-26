import 'package:flutter/services.dart';

/// 숫자 입력을 [min]~[max] 범위로 막습니다. 뒤에 숫자를 더 쳐도 범위에 들 수 없는 입력은 받지 않습니다.
/// 예) 월(1~12): `0`, `1`은 받고 `00`, `13`은 막습니다. 년도(1900~2026): `2`는 받고 `3`, `203`은 막습니다.
/// [accepts]를 주면 범위 안에서도 그 조건을 통과하는 값으로만 끝낼 수 있게 합니다.
/// 입력할 때마다 다시 부르므로 다른 칸 값에 따라 결과가 바뀌어도 됩니다.
/// 자릿수는 [max]의 자릿수까지만 받습니다. 숫자만 남기는 포매터 뒤에 두세요.
class NumberRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;
  final bool Function(int value)? accepts;

  const NumberRangeFormatter({required this.min, required this.max, this.accepts});

  int get maxDigits => max.toString().length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (text.length > maxDigits) return oldValue;

    final value = int.tryParse(text);
    if (value == null || !_canComplete(value, text.length)) return oldValue;
    return newValue;
  }

  /// [value]에 숫자를 0개 이상 더 붙여 범위 안이면서 [accepts]를 통과하는 값을 만들 수 있는지 봅니다.
  bool _canComplete(int value, int length) {
    var lowest = value;
    var span = 1;
    for (var digits = length; digits <= maxDigits; digits++) {
      final from = lowest < min ? min : lowest;
      final to = lowest + span - 1 > max ? max : lowest + span - 1;
      for (var candidate = from; candidate <= to; candidate++) {
        if (accepts?.call(candidate) ?? true) return true;
      }
      lowest *= 10;
      span *= 10;
    }
    return false;
  }
}
