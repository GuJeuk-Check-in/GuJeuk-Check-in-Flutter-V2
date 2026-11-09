import 'package:flutter/services.dart';

/// 휴대폰 번호를 `010-1234-5678` 형태로 하이픈을 넣어 보여줍니다.
/// 숫자만 받고 최대 11자리까지 입력됩니다. 서버로 보낼 때는 [digitsOf]로 하이픈을 빼세요.
class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter();

  static const int maxDigits = 11;

  static String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  static final _validPattern = RegExp(r'^01[016789]\d{7,8}$');

  /// 하이픈을 뺀 숫자가 휴대폰 번호 모양인지. 회원가입과 동명이인 확인이 같은 규칙을 씁니다.
  static bool isValid(String text) => _validPattern.hasMatch(digitsOf(text));

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOf(newValue.text);
    final cursor = newValue.selection.end.clamp(0, newValue.text.length);
    var digitsBeforeCursor = digitsOf(newValue.text.substring(0, cursor)).length;

    // 하이픈만 지웠을 때는 지운 방향의 숫자를 지워 커서가 하이픈에서 멈추지 않게 합니다.
    // 커서가 그대로면 Delete(앞으로 지우기)라 뒤 숫자를, 아니면 백스페이스라 앞 숫자를 지웁니다.
    final deletedOnlyHyphen = newValue.text.length < oldValue.text.length &&
        digits == digitsOf(oldValue.text);
    final deletedForward = oldValue.selection.isCollapsed &&
        oldValue.selection.end == newValue.selection.end;
    if (deletedOnlyHyphen && deletedForward) {
      if (digitsBeforeCursor < digits.length) {
        digits = digits.substring(0, digitsBeforeCursor) +
            digits.substring(digitsBeforeCursor + 1);
      }
    } else if (deletedOnlyHyphen && digitsBeforeCursor > 0) {
      digits = digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
      if (digitsBeforeCursor > maxDigits) digitsBeforeCursor = maxDigits;
    }

    final formatted = format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitsBeforeCursor),
      ),
    );
  }

  /// 숫자만 담긴 [digits]에 하이픈을 넣습니다. 서버로 보낼 때도 같은 모양을 씁니다.
  /// 10자리 01X 번호(011·016·017·018·019)는 `011-123-4567`로 나눕니다.
  /// 010은 항상 11자리라 10자리일 때는 아직 치는 중으로 보고, 마지막 자리에서 칸이 옮겨 가지 않게 3-4-3으로 둡니다.
  static String format(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length == 10 && !digits.startsWith('010')) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
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
