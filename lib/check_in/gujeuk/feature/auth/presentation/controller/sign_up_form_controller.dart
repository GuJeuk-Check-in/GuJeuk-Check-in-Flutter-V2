import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';

/// 회원가입 폼의 입력값과 에러 문구를 한곳에서 관리합니다.
/// [validate]로 전체를 검사하고, 값을 다시 고치면 그 항목의 에러는 지워집니다.
class SignUpFormController extends ChangeNotifier {
  final ReservationRepository _reservations;

  // 예약 API는 마감된 시간만 주므로 고를 수 있는 시간 전체는 앱에서 정합니다.
  static const times = [
    '09:30',
    '10:30',
    '11:30',
    '12:30',
    '13:30',
    '14:30',
    '15:30',
    '16:30',
    '17:30',
  ];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthYearController = TextEditingController();
  final birthMonthController = TextEditingController();
  final birthDayController = TextEditingController();
  final residenceController = TextEditingController();

  /// 고른 방문 목적. API와 같은 `친친마루(게임, 독서 등)` 모양입니다.
  String? purpose;
  String? time;

  /// 카드로 보여줄 전체 방문 목적. null이면 아직 못 불러왔습니다.
  List<VisitPurpose>? visitPurposes;

  /// 예약이 필요한 목적 이름들. null이면 아직 못 불러왔습니다.
  Set<String>? reservablePurposes;
  String? purposesLoadError;

  /// 고른 시설의 오늘 마감 시간. null이면 불러오는 중이거나 실패했습니다.
  Set<String>? reservedTimes;
  String? reservedLoadError;
  var _reservedRequest = 0;
  var _disposed = false;
  GujeukGender? gender;
  String? residence;
  bool agreed = false;
  int maleCount = 0;
  int femaleCount = 0;

  String? purposeError;
  String? timeError;
  String? nameError;
  String? phoneError;
  String? genderError;
  String? birthError;
  String? residenceError;
  String? agreementError;
  String? companionError;

  SignUpFormController(this._reservations) {
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

  /// 고른 목적이 예약이 필요한 시설이라 시간도 골라야 하는지.
  bool get needsTime => reservablePurposes?.contains(purpose) ?? false;

  /// 오늘 시작 시간이 이미 지난 칸. 화면을 띄워둔 사이에도 지나가므로 부를 때마다 다시 셉니다.
  Set<String> get pastTimes {
    final now = DateTime.now();
    return {
      for (final t in times)
        if (!_todayAt(t, now).isAfter(now)) t,
    };
  }

  static DateTime _todayAt(String time, DateTime now) {
    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(3, 5));
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 본인을 뺀 동행 최대 인원. 정원이 없는 시설이면 null입니다.
  int? get maxCompanions {
    final maxPeople = visitPurposes
        ?.where((p) => p.purpose == purpose)
        .firstOrNull
        ?.maxPeople;
    return maxPeople == null ? null : maxPeople - 1;
  }

  /// 전체 방문 목적과 예약이 필요한 시설을 함께 받습니다.
  /// 예약이 필요 없는 목적도 카드로 보이고, 고르면 시간 없이 제출할 수 있습니다.
  Future<void> loadPurposes() async {
    purposesLoadError = null;
    notifyListeners();
    try {
      final (all, reservable) = await (
        _reservations.fetchVisitPurposes(),
        _reservations.fetchReservablePurposes(),
      ).wait;
      visitPurposes = all;
      reservablePurposes = {for (final p in reservable) p.purpose};
    } catch (_) {
      purposesLoadError = '방문 목적을 불러오지 못했어요';
    }
    if (_disposed) return;
    // 목록이 오기 전에 이미 목적을 골랐다면 이제 마감 시간을 불러옵니다.
    if (needsTime) {
      loadReservedTimes();
    } else {
      notifyListeners();
    }
  }

  void selectPurpose(String value) {
    if (purpose == value) return;
    // 시설마다 예약 상황이 다르므로 목적을 바꾸면 고른 시간은 비웁니다.
    time = null;
    timeError = null;
    purpose = value;
    purposeError = null;
    // 정원이 더 작은 시설로 바꿨다면 고른 인원을 지우지 않고 바로 알려줍니다.
    companionError = _validateCompanions();
    // 이전 목적의 마감 시간 응답이 늦게 와도 버려지게 합니다.
    _reservedRequest++;
    reservedTimes = null;
    reservedLoadError = null;
    if (needsTime) {
      loadReservedTimes();
    } else {
      notifyListeners();
    }
  }

  /// 오늘 예약 전체를 받아 고른 시설 것만 남깁니다.
  Future<void> loadReservedTimes() async {
    final selected = purpose;
    if (selected == null) return;
    // 응답을 기다리는 사이 다른 시설을 고르면 늦게 온 이전 응답은 버립니다.
    final request = ++_reservedRequest;
    reservedTimes = null;
    reservedLoadError = null;
    notifyListeners();
    try {
      final slots = await _reservations.fetchReservedSlots();
      if (request != _reservedRequest) return;
      reservedTimes = {
        for (final slot in slots)
          if (slot.purpose == selected) slot.startTime,
      };
      if (reservedTimes!.contains(time)) time = null;
    } catch (_) {
      if (request != _reservedRequest) return;
      reservedLoadError = '예약 현황을 불러오지 못했어요';
    }
    if (!_disposed) notifyListeners();
  }

  /// 제출하는 사이 다른 친구가 고른 시간을 예약했을 때.
  /// 현황을 다시 불러오면 그 칸이 마감으로 바뀌고 고른 시간도 비워집니다.
  void rejectTakenTime() {
    timeError = '그사이 다른 친구가 예약했어요. 다른 시간을 골라주세요';
    loadReservedTimes();
  }

  /// 같은 이름의 회원이 있어 전화번호를 붙여 보냈는데도 번호가 맞지 않을 때.
  /// 번호를 고치면 phoneController 리스너가 에러를 지웁니다.
  void rejectDuplicatePhone() {
    phoneError = '같은 이름의 친구와 전화번호가 달라요. 전화번호를 다시 확인해주세요';
    notifyListeners();
  }

  void selectTime(String value) {
    time = value;
    timeError = null;
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
    companionError = _validateCompanions();
    notifyListeners();
  }

  void setFemaleCount(int value) {
    femaleCount = value;
    companionError = _validateCompanions();
    notifyListeners();
  }

  /// 생년월일 칸에 이 값을 넣어도 되는지. 다른 두 칸에 이미 친 값과 합쳐
  /// 오늘 이후 날짜나 없는 날짜(4월 31일, 평년 2월 29일 등)가 되면 막습니다.
  /// 어느 칸부터 치든 같은 규칙이 걸리도록 세 칸 모두 같은 검사를 씁니다.
  bool canBeBirthYear(int year) =>
      _isPossibleBirth(year, _birthMonth, _birthDay);

  bool canBeBirthMonth(int month) =>
      _isPossibleBirth(_birthYear, month, _birthDay);

  bool canBeBirthDay(int day) => _isPossibleBirth(_birthYear, _birthMonth, day);

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
    timeError = _validateTime();
    companionError = _validateCompanions();
    nameError = nameController.text.trim().isEmpty ? '이름을 적어주세요' : null;
    phoneError = _validatePhone();
    genderError = gender == null ? '성별을 골라주세요' : null;
    birthError = _validateBirth();
    residenceError = residence == null ? '사는 동네를 골라주세요' : null;
    agreementError = agreed ? null : '개인정보 수집 및 이용에 동의해주세요';
    notifyListeners();

    return [
      purposeError,
      timeError,
      nameError,
      phoneError,
      genderError,
      birthError,
      residenceError,
      agreementError,
      companionError,
    ].every((error) => error == null);
  }

  /// 이용 예약 화면용 검사. 개인정보 칸이 없으므로 목적·시간·인원만 봅니다.
  bool validateReservation() {
    purposeError = purpose == null ? '무엇을 하러 왔는지 골라주세요' : null;
    timeError = _validateTime();
    companionError = _validateCompanions();
    notifyListeners();

    return purposeError == null && timeError == null && companionError == null;
  }

  /// 시간 칸은 예약이 필요한 시설을 골랐을 때만 보이므로 그때만 검사합니다.
  /// 고른 뒤 폼을 쓰는 사이 시작 시간이 지났다면 고른 시간을 비웁니다.
  String? _validateTime() {
    if (!needsTime) return null;
    final selected = time;
    if (selected == null) return '몇 시에 이용할지 골라주세요';
    if (pastTimes.contains(selected)) {
      time = null;
      return '이미 지난 시간이에요. 다른 시간을 골라주세요';
    }
    return null;
  }

  String? _validateCompanions() {
    final max = maxCompanions;
    if (max == null || maleCount + femaleCount <= max) return null;
    return '이 시설은 본인 포함 최대 ${max + 1}명까지 쓸 수 있어요';
  }

  String? _validatePhone() {
    final text = phoneController.text;
    if (PhoneNumberFormatter.digitsOf(text).isEmpty) return '전화번호를 적어주세요';
    if (!PhoneNumberFormatter.isValid(text)) return '전화번호를 다시 확인해주세요';
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
    _disposed = true;
    nameController.dispose();
    phoneController.dispose();
    birthYearController.dispose();
    birthMonthController.dispose();
    birthDayController.dispose();
    residenceController.dispose();
    super.dispose();
  }
}
