import 'package:flutter/widgets.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';

/// 회원가입 화면에서 직접 타이핑하는 칸들의 컨트롤러. 화면이 만들고 dispose합니다.
/// 값은 Notifier 상태에 두지 않아, 타이핑할 때마다 폼 전체가 다시 그려지지 않습니다.
class SignUpTextFields {
  final TextEditingController name;
  final phone = TextEditingController();
  final birthYear = TextEditingController();
  final birthMonth = TextEditingController();
  final birthDay = TextEditingController();

  /// 모달에서 고른 동네를 보여주기만 하는 칸입니다.
  final residence = TextEditingController();

  /// [onEdited]는 칸을 고칠 때마다 그 항목으로 불립니다. 떠 있는 에러를 지우는 데 씁니다.
  /// [initialName]은 이름 확인에서 이미 적은 이름입니다.
  SignUpTextFields({
    required void Function(SignUpField field) onEdited,
    String initialName = '',
  }) : name = TextEditingController(text: initialName) {
    name.addListener(() => onEdited(SignUpField.name));
    phone.addListener(() => onEdited(SignUpField.phone));
    for (final controller in [birthYear, birthMonth, birthDay]) {
      controller.addListener(() => onEdited(SignUpField.birth));
    }
  }

  SignUpTexts get values => (
    name: name.text,
    phone: phone.text,
    birthYear: birthYear.text,
    birthMonth: birthMonth.text,
    birthDay: birthDay.text,
  );

  /// 생년월일 칸에 이 값을 넣어도 되는지. 다른 두 칸에 이미 친 값과 합쳐
  /// 오늘 이후 날짜나 없는 날짜(4월 31일, 평년 2월 29일 등)가 되면 막습니다.
  /// 어느 칸부터 치든 같은 규칙이 걸리도록 세 칸 모두 같은 검사를 씁니다.
  bool canBeBirthYear(int year) =>
      _isPossibleBirth(year, _birthMonth, _birthDay);

  bool canBeBirthMonth(int month) =>
      _isPossibleBirth(_birthYear, month, _birthDay);

  bool canBeBirthDay(int day) => _isPossibleBirth(_birthYear, _birthMonth, day);

  /// 아직 안 친 칸(null)은 어떤 값이든 될 수 있다고 봅니다.
  static bool _isPossibleBirth(int? year, int? month, int? day) {
    if (month != null && day != null) {
      // 년도를 모르면 2월 29일도 받도록 윤년(2000)으로 셉니다.
      final daysInMonth = DateTime(year ?? 2000, month + 1, 0).day;
      if (day > daysInMonth) return false;
    }
    if (year == null) return true;
    // 안 친 월·일은 가장 이른 1월·1일로 놓고 오늘 이후인지 봅니다.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !DateTime(year, month ?? 1, day ?? 1).isAfter(today);
  }

  /// 4자리를 다 쳤을 때만 년도로 봅니다.
  int? get _birthYear {
    final text = birthYear.text;
    return text.length == 4 ? int.parse(text) : null;
  }

  int? get _birthMonth => _parseIn(birthMonth.text, 1, 12);

  int? get _birthDay => _parseIn(birthDay.text, 1, 31);

  static int? _parseIn(String text, int min, int max) {
    final value = int.tryParse(text);
    return value != null && value >= min && value <= max ? value : null;
  }

  void dispose() {
    name.dispose();
    phone.dispose();
    birthYear.dispose();
    birthMonth.dispose();
    birthDay.dispose();
    residence.dispose();
  }
}
