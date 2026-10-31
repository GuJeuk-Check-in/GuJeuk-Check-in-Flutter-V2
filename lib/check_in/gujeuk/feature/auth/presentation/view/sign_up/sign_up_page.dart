import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/bottom.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  /// 웹과 같은 카드 최대 너비. 1920 화면에서 좌우 448씩 여백이 생깁니다.
  /// 고정 여백 대신 최대 너비로 잡아 작은 화면에서도 깨지지 않게 합니다.
  static const double _cardMaxWidth = 1232;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  late final ReservationRepository _reservations = ref.read(
    reservationRepositoryProvider,
  );
  late final SignUpRepository _signUps = ref.read(signUpRepositoryProvider);
  late final SignUpFormController _form = SignUpFormController(_reservations);

  /// 요청하는 동안 버튼을 다시 눌러도 무시합니다.
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _form.loadPurposes();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!_form.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      if (!await _signUp()) return;
      if (!mounted) return;
      _goToEnd();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 가입에 성공하면 true, 실패하면 문구를 화면에 띄우고 false.
  /// 예약이 필요한 시설이면 가입 요청에 시간을 실어 한 번에 예약합니다.
  Future<bool> _signUp() async {
    try {
      await _signUps.signUp(
        name: _form.nameController.text.trim(),
        gender: switch (_form.gender!) {
          GujeukGender.male => Gender.man,
          GujeukGender.female => Gender.woman,
        },
        phone: PhoneNumberFormatter.digitsOf(_form.phoneController.text),
        birthDate: _form.birthDate,
        residence: _form.residence!,
        purpose: _form.purpose!,
        maleCount: _form.maleCount,
        femaleCount: _form.femaleCount,
        reservationTime: _form.needsTime ? _form.time : null,
      );
      return true;
    } on SlotTakenException {
      if (mounted) _form.rejectTakenTime();
      return false;
    } catch (_) {
      if (mounted) setState(() => _submitError = '가입하지 못했어요. 다시 눌러주세요');
      return false;
    }
  }

  void _goToEnd() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationEndPage(
          reservation: _form.needsTime
              ? ReservationInfo(
                  name: _form.nameController.text.trim(),
                  purpose: _form.purpose!,
                  phone: _form.phoneController.text.trim(),
                  startTime: _form.time!,
                  maleCount: _form.maleCount,
                  femaleCount: _form.femaleCount,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s100),
        child: Container(
          constraints: const BoxConstraints(maxWidth: SignUpPage._cardMaxWidth),
          padding: EdgeInsets.all(GujeukSpacing.s64),
          decoration: BoxDecoration(
            border: Border.all(color: GujeukColors.borderCard, width: 4),
            boxShadow: GujeukShadows.card,
            color: GujeukColors.bgSurface,
            borderRadius: BorderRadius.circular(GujeukRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(title: '구즉 청소년문화의 집에 온걸 환영해~!'),
              const SizedBox(height: GujeukSpacing.s40),
              Middle(form: _form, isSigned: false),
              const SizedBox(height: GujeukSpacing.s100),
              Bottom(
                form: _form,
                onSubmit: _onSubmit,
                isSubmitting: _isSubmitting,
                submitError: _submitError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
