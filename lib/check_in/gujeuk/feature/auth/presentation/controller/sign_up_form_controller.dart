import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';

/// 회원가입 폼의 입력값과 에러 문구를 한곳에서 관리합니다.
/// [validate]로 전체를 검사하고, 값을 다시 고치면 그 항목의 에러는 지워집니다.
class SignUpFormController extends ChangeNotifier {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthYearController = TextEditingController();
  final birthMonthController = TextEditingController();
  final birthDayController = TextEditingController();
  final residenceController = TextEditingController();

  int? purpose;
  GujeukGender? gender;
  String? residence;
  bool agreed = false;
  int maleCount = 0;
  int femaleCount = 0;

  String? purposeError;
  String? nameError;
  String? phoneError;
  String? genderError;
  String? birthError;
  String? residenceError;
  String? agreementError;

  static final _phonePattern = RegExp(r'^01[016789]\d{7,8}$');

  SignUpFormController() {
    // 에러가 떠 있을 때만 지우고 다시 그려, 타이핑마다 폼 전체가 다시 그려지지 않게 합니다.
    nameController.addListener(() {
      if (nameError == null) return;
      nameError = null;
      notifyListeners();
    });
    phoneController.addListener(() {
      if (phoneError == null) return;
      phoneError = null;
      notifyListeners();
    });
    for (final controller in [
      birthYearController,
      birthMonthController,
      birthDayController,
    ]) {
      controller.addListener(() {
        if (birthError == null) return;
        birthError = null;
        notifyListeners();
      });
    }
  }

  void selectPurpose(int value) {
    purpose = value;
    purposeError = null;
    notifyListeners();
  }

  void selectGender(GujeukGender value) {
    gender = value;
    genderError = null;
    notifyListeners();
  }

  void selectResidence(String value) {
    residence = value;
    residenceController.text = value;
    residenceError = null;
    notifyListeners();
  }

  void setAgreed(bool value) {
    agreed = value;
    if (value) agreementError = null;
    notifyListeners();
  }

  void setMaleCount(int value) {
    maleCount = value;
    notifyListeners();
  }

  void setFemaleCount(int value) {
    femaleCount = value;
    notifyListeners();
  }

  /// 생년월일 칸에 이 값을 넣어도 되는지. 다른 두 칸에 이미 친 값과 합쳐
  /// 오늘 이후 날짜나 없는 날짜(4월 31일, 평년 2월 29일 등)가 되면 막습니다.
  /// 어느 칸부터 치든 같은 규칙이 걸리도록 세 칸 모두 같은 검사를 씁니다.
  bool canBeBirthYear(int year) =>
      _isPossibleBirth(year, _birthMonth, _birthDay);

  bool canBeBirthMonth(int month) =>
      _isPossibleBirth(_birthYear, month, _birthDay);

  bool canBeBirthDay(int day) =>
      _isPossibleBirth(_birthYear, _birthMonth, day);

  /// 아직 안 친 칸(null)은 어떤 값이든 될 수 있다고 봅니다.
  bool _isPossibleBirth(int? year, int? month, int? day) {
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
    final text = birthYearController.text;
    return text.length == 4 ? int.parse(text) : null;
  }

  int? get _birthMonth => _parseIn(birthMonthController.text, 1, 12);

  int? get _birthDay => _parseIn(birthDayController.text, 1, 31);

  static int? _parseIn(String text, int min, int max) {
    final value = int.tryParse(text);
    return value != null && value >= min && value <= max ? value : null;
  }

  /// 모든 항목을 검사해 에러 문구를 채웁니다. 전부 통과하면 true.
  bool validate() {
    purposeError = purpose == null ? '무엇을 하러 왔는지 골라주세요' : null;
    nameError = nameController.text.trim().isEmpty ? '이름을 적어주세요' : null;
    phoneError = _validatePhone();
    genderError = gender == null ? '성별을 골라주세요' : null;
    birthError = _validateBirth();
    residenceError = residence == null ? '사는 동네를 골라주세요' : null;
    agreementError = agreed ? null : '개인정보 수집 및 이용에 동의해주세요';
    notifyListeners();

    return [
      purposeError,
      nameError,
      phoneError,
      genderError,
      birthError,
      residenceError,
      agreementError,
    ].every((error) => error == null);
  }

  String? _validatePhone() {
    final digits = PhoneNumberFormatter.digitsOf(phoneController.text);
    if (digits.isEmpty) return '전화번호를 적어주세요';
    if (!_phonePattern.hasMatch(digits)) return '전화번호를 다시 확인해주세요';
    return null;
  }

  String? _validateBirth() {
    final yearText = birthYearController.text;
    final monthText = birthMonthController.text;
    final dayText = birthDayController.text;
    if (yearText.isEmpty || monthText.isEmpty || dayText.isEmpty) {
      return '생년월일을 적어주세요';
    }

    final year = int.parse(yearText);
    final month = int.parse(monthText);
    final day = int.parse(dayText);
    // DateTime은 2월 30일을 3월 2일로 넘겨버리므로, 만든 뒤 값이 그대로인지 봅니다.
    final birth = DateTime(year, month, day);
    final isRealDate =
        birth.year == year && birth.month == month && birth.day == day;
    if (year < 1900 || !isRealDate || birth.isAfter(DateTime.now())) {
      return '생년월일을 다시 확인해주세요';
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthYearController.dispose();
    birthMonthController.dispose();
    birthDayController.dispose();
    residenceController.dispose();
    super.dispose();
  }
}
