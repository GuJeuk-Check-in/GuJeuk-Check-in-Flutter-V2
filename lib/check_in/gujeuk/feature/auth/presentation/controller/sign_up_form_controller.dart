import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_options.dart';

/// 에러 문구를 띄우는 폼 항목.
enum SignUpField {
  purpose,
  time,
  companion,
  name,
  phone,
  gender,
  birth,
  residence,
  agreement,
}

/// 회원가입 화면에서 직접 타이핑하는 칸들의 값. 제출할 때 [SignUpFormController.validate]에 넘깁니다.
typedef SignUpTexts = ({
  String name,
  String phone,
  String birthYear,
  String birthMonth,
  String birthDay,
});

/// 고른 값과 에러 문구. 타이핑하는 칸의 값은 화면의 TextEditingController가 들고 있습니다.
@immutable
class SignUpFormState {
  /// 고른 방문 목적. API와 같은 `친친마루(게임, 독서 등)` 모양입니다.
  final String? purpose;
  final String? time;
  final GujeukGender? gender;
  final String? residence;
  final bool agreed;
  final int maleCount;
  final int femaleCount;
  final Map<SignUpField, String> errors;

  const SignUpFormState({
    this.purpose,
    this.time,
    this.gender,
    this.residence,
    this.agreed = false,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.errors = const {},
  });

  String? errorOf(SignUpField field) => errors[field];

  static const _keep = Object();

  /// [purpose]와 [time]은 null로 비울 수 있어, 넘기지 않은 것과 구분하려고 [_keep]을 씁니다.
  SignUpFormState copyWith({
    Object? purpose = _keep,
    Object? time = _keep,
    GujeukGender? gender,
    String? residence,
    bool? agreed,
    int? maleCount,
    int? femaleCount,
    Map<SignUpField, String>? errors,
  }) {
    return SignUpFormState(
      purpose: identical(purpose, _keep) ? this.purpose : purpose as String?,
      time: identical(time, _keep) ? this.time : time as String?,
      gender: gender ?? this.gender,
      residence: residence ?? this.residence,
      agreed: agreed ?? this.agreed,
      maleCount: maleCount ?? this.maleCount,
      femaleCount: femaleCount ?? this.femaleCount,
      errors: errors ?? this.errors,
    );
  }
}

/// 회원가입·이용 예약 화면이 함께 쓰는 폼. 화면을 떠나면 비워집니다.
final signUpFormProvider =
    NotifierProvider.autoDispose<SignUpFormController, SignUpFormState>(
      SignUpFormController.new,
    );

/// 고른 값과 에러 문구를 한곳에서 관리합니다.
/// [validate]로 전체를 검사하고, 값을 다시 고치면 그 항목의 에러는 지워집니다.
class SignUpFormController extends Notifier<SignUpFormState> {
  // 예약 API는 예약 가능한 시간만 주므로 화면에 보여줄 칸 전체는 앱에서 정합니다.
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

  /// 고른 시설의 예약 가능한 시간을 지켜봅니다. 시설을 바꾸면 이전 것은 닫습니다.
  ProviderSubscription<AsyncValue<Set<String>>>? _availableTimesSub;

  @override
  SignUpFormState build() => const SignUpFormState();

  PurposeCatalog? get _catalog => ref.read(purposeCatalogProvider).value;

  /// 고른 목적이 예약이 필요한 시설이라 시간도 골라야 하는지.
  bool get needsTime => _catalog?.needsTime(state.purpose) ?? false;

  /// 오늘 시작 시간이 이미 지난 칸. 화면을 띄워둔 사이에도 지나가므로 부를 때마다 다시 셉니다.
  static Set<String> pastTimes() {
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

  void selectPurpose(String value) {
    if (state.purpose == value) return;
    // 시설마다 예약 상황이 다르므로 목적을 바꾸면 고른 시간은 비웁니다.
    // 정원이 더 작은 시설로 바꿨다면 고른 인원을 지우지 않고 바로 알려줍니다.
    state = state.copyWith(
      purpose: value,
      time: null,
      errors: _withErrors({
        SignUpField.purpose: null,
        SignUpField.time: null,
        SignUpField.companion: _companionError(
          value,
          state.maleCount + state.femaleCount,
        ),
      }),
    );
    _watchAvailableTimes();
  }

  /// 예약 가능한 시간을 받았는데 고른 시간이 없으면 고른 시간을 비웁니다.
  void _watchAvailableTimes() {
    _availableTimesSub?.close();
    _availableTimesSub = null;
    final purpose = state.purpose;
    if (purpose == null || !needsTime) return;
    _availableTimesSub = ref.listen(availableTimesProvider(purpose), (_, next) {
      final available = next.value;
      final time = state.time;
      if (available != null && time != null && !available.contains(time)) {
        state = state.copyWith(time: null);
      }
    });
  }

  /// 제출하는 사이 다른 친구가 고른 시간을 예약했을 때.
  /// 현황을 다시 불러오면 그 칸이 마감으로 바뀌고 고른 시간도 비워집니다.
  void rejectTakenTime() {
    state = state.copyWith(
      errors: _withErrors({SignUpField.time: '그사이 다른 친구가 예약했어요. 다른 시간을 골라주세요'}),
    );
    final purpose = state.purpose;
    if (purpose != null) ref.invalidate(availableTimesProvider(purpose));
  }

  void selectTime(String value) {
    state = state.copyWith(
      time: value,
      errors: _withErrors({SignUpField.time: null}),
    );
  }

  void selectGender(GujeukGender value) {
    state = state.copyWith(
      gender: value,
      errors: _withErrors({SignUpField.gender: null}),
    );
  }

  void selectResidence(String value) {
    state = state.copyWith(
      residence: value,
      errors: _withErrors({SignUpField.residence: null}),
    );
  }

  void setAgreed(bool value) {
    state = state.copyWith(
      agreed: value,
      errors: value ? _withErrors({SignUpField.agreement: null}) : null,
    );
  }

  void setMaleCount(int value) {
    state = state.copyWith(
      maleCount: value,
      errors: _withErrors({
        SignUpField.companion: _companionError(
          state.purpose,
          value + state.femaleCount,
        ),
      }),
    );
  }

  void setFemaleCount(int value) {
    state = state.copyWith(
      femaleCount: value,
      errors: _withErrors({
        SignUpField.companion: _companionError(
          state.purpose,
          state.maleCount + value,
        ),
      }),
    );
  }

  /// 타이핑하는 칸을 고쳤을 때. 에러가 떠 있을 때만 지우고 다시 그려,
  /// 타이핑마다 폼 전체가 다시 그려지지 않게 합니다.
  void clearError(SignUpField field) {
    if (!state.errors.containsKey(field)) return;
    state = state.copyWith(errors: _withErrors({field: null}));
  }

  /// 모든 항목을 검사해 에러 문구를 채웁니다. 전부 통과하면 true.
  bool validate(SignUpTexts texts) {
    final s = state;
    return _applyErrors({
      ..._visitErrors(),
      if (texts.name.trim().isEmpty) SignUpField.name: '이름을 적어주세요',
      SignUpField.phone: ?_phoneError(texts.phone),
      if (s.gender == null) SignUpField.gender: '성별을 골라주세요',
      SignUpField.birth: ?_birthError(texts),
      if (s.residence == null) SignUpField.residence: '사는 동네를 골라주세요',
      if (!s.agreed) SignUpField.agreement: '개인정보 수집 및 이용에 동의해주세요',
    });
  }

  /// 이용 예약 화면용 검사. 개인정보 칸이 없으므로 목적·시간·인원만 봅니다.
  bool validateReservation() => _applyErrors(_visitErrors());

  bool _applyErrors(Map<SignUpField, String> errors) {
    // 고른 뒤 폼을 쓰는 사이 시작 시간이 지났다면 고른 시간을 비웁니다.
    final time = state.time;
    final passed = time != null && pastTimes().contains(time);
    state = state.copyWith(time: passed ? null : time, errors: errors);
    return errors.isEmpty;
  }

  /// 목적·시간·인원 검사. 두 화면 모두 씁니다.
  Map<SignUpField, String> _visitErrors() {
    final s = state;
    return {
      if (s.purpose == null) SignUpField.purpose: '무엇을 하러 왔는지 골라주세요',
      SignUpField.time: ?_timeError(),
      SignUpField.companion: ?_companionError(
        s.purpose,
        s.maleCount + s.femaleCount,
      ),
    };
  }

  /// 시간 칸은 예약이 필요한 시설을 골랐을 때만 보이므로 그때만 검사합니다.
  String? _timeError() {
    if (!needsTime) return null;
    final time = state.time;
    if (time == null) return '몇 시에 이용할지 골라주세요';
    if (pastTimes().contains(time)) return '이미 지난 시간이에요. 다른 시간을 골라주세요';
    return null;
  }

  String? _companionError(String? purpose, int companions) {
    final max = _catalog?.maxCompanions(purpose);
    if (max == null || companions <= max) return null;
    return '이 시설은 본인 포함 최대 ${max + 1}명까지 쓸 수 있어요';
  }

  static String? _phoneError(String text) {
    if (PhoneNumberFormatter.digitsOf(text).isEmpty) return '전화번호를 적어주세요';
    if (!PhoneNumberFormatter.isValid(text)) return '전화번호를 다시 확인해주세요';
    return null;
  }

  /// 생년월일. [validate]를 통과한 값에만 씁니다.
  static DateTime birthDateOf(SignUpTexts texts) => DateTime(
    int.parse(texts.birthYear),
    int.parse(texts.birthMonth),
    int.parse(texts.birthDay),
  );

  static String? _birthError(SignUpTexts texts) {
    final (:birthYear, :birthMonth, :birthDay, name: _, phone: _) = texts;
    if (birthYear.isEmpty || birthMonth.isEmpty || birthDay.isEmpty) {
      return '생년월일을 적어주세요';
    }

    final year = int.parse(birthYear);
    final month = int.parse(birthMonth);
    final day = int.parse(birthDay);
    // DateTime은 2월 30일을 3월 2일로 넘겨버리므로, 만든 뒤 값이 그대로인지 봅니다.
    final birth = DateTime(year, month, day);
    final isRealDate =
        birth.year == year && birth.month == month && birth.day == day;
    if (year < 1900 || !isRealDate || birth.isAfter(DateTime.now())) {
      return '생년월일을 다시 확인해주세요';
    }
    return null;
  }

  /// 지금 에러에 [changes]를 덮어씁니다. 값이 null이면 그 항목의 에러를 지웁니다.
  Map<SignUpField, String> _withErrors(Map<SignUpField, String?> changes) {
    final errors = {...state.errors};
    for (final MapEntry(:key, :value) in changes.entries) {
      if (value == null) {
        errors.remove(key);
      } else {
        errors[key] = value;
      }
    }
    return errors;
  }
}
