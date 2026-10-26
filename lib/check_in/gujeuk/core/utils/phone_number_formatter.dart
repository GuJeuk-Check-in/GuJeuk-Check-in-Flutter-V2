import 'package:flutter/services.dart';

/// 휴대폰 번호를 `010-1234-5678` 형태로 하이픈을 넣어 보여줍니다.
/// 숫자만 받고 최대 11자리까지 입력됩니다. 서버로 보낼 때는 [digitsOf]로 하이픈을 빼세요.
class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter();

  static const int maxDigits = 11;

  static String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOf(newValue.text);
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    var digitsBeforeCursor = digitsOf(newValue.text.substring(0, cursor)).length;

    // 하이픈만 지웠을 때는 바로 앞 숫자를 지워 커서가 하이픈에서 멈추지 않게 합니다.
    final deletedOnlyHyphen = newValue.text.length < oldValue.text.length &&
        digits == digitsOf(oldValue.text);
    if (deletedOnlyHyphen && digitsBeforeCursor > 0) {
      digits = digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
      if (digitsBeforeCursor > maxDigits) digitsBeforeCursor = maxDigits;
    }

    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitsBeforeCursor),
      ),
    );
  }

  static String _format(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }

  /// 포맷된 문자열에서 숫자 [count]개 뒤의 위치를 돌려줍니다.
  static int _offsetAfterDigits(String formatted, int count) {
    if (count == 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (formatted[i] != '-' && ++seen == count) return i + 1;
    }
    return formatted.length;
  }
}
