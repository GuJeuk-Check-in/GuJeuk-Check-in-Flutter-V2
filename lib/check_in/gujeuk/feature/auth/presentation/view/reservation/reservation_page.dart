import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/base_scaffold.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/color.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/radius.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/shadow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/spacing.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/typography.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/fake_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/phone_check_dialog.dart';

class ReservationPage extends StatefulWidget {
  final String name;

  const ReservationPage({super.key, required this.name});

  static const double _cardMaxWidth = 1232;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // 퍼블리싱용 가짜 응답입니다. 서버 연동 때 실제 구현으로 바꿉니다.
  final ReservationRepository _reservations = const FakeReservationRepository();
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
    if (!_form.validateReservation()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      if (_form.needsTime) {
        await _reserve();
      } else {
        // TODO 예약이 필요 없는 목적은 방문 기록(check-in) 요청
        _goToEnd(null);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 처음엔 전화번호 없이 보내고, 같은 이름의 회원이 있다는 409가 오면
  /// 전화번호를 받아 같은 내용으로 한 번 더 보냅니다.
  /// 번호를 보냈는데도 409면 서버에 있는 번호와 다른 것이라 에러와 함께 다시 묻습니다.
  Future<void> _reserve({String? phone}) async {
    try {
      await _reservations.reserve(
        name: widget.name,
        phone: phone == null ? null : PhoneNumberFormatter.digitsOf(phone),
        purpose: _form.purpose!,
        startTime: _form.time!,
        maleCount: _form.maleCount,
        femaleCount: _form.femaleCount,
      );
    } on DuplicateNameException {
      if (!mounted) return;
      final entered = await PhoneCheckDialog.show(
        context,
        errorText: phone == null ? null : '전화번호가 달라요. 다시 확인해주세요',
      );
      // 취소하면 예약 화면에 그대로 남아 다시 누를 수 있습니다.
      if (entered == null || !mounted) return;
      return _reserve(phone: entered);
    } on SlotTakenException {
      if (mounted) _form.rejectTakenTime();
      return;
    } catch (_) {
      if (mounted) setState(() => _submitError = '예약하지 못했어요. 다시 눌러주세요');
      return;
    }
    if (!mounted) return;

    _goToEnd(
      ReservationInfo(
        name: widget.name,
        purpose: _form.purpose!,
        phone: phone ?? '',
        startTime: _form.time!,
        maleCount: _form.maleCount,
        femaleCount: _form.femaleCount,
      ),
    );
  }

  /// [reservation]이 null이면 예약 없이 바로 이용하는 완료 화면을 띄웁니다.
  void _goToEnd(ReservationInfo? reservation) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationEndPage(reservation: reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s100),
        child: Container(
          constraints: BoxConstraints(maxWidth: ReservationPage._cardMaxWidth),
          padding: EdgeInsets.all(GujeukSpacing.s64),
          decoration: BoxDecoration(
            border: Border.all(color: GujeukColors.borderCard, width: 4),
            boxShadow: GujeukShadows.card,
            color: GujeukColors.bgSurface,
            borderRadius: BorderRadius.circular(GujeukRadius.xl),
          ),
          child: Column(
            children: [
              Header(title: '반가워! 청소년문화의집에 다시 와줘서 고마워'),
              const SizedBox(height: GujeukSpacing.s40),
              Middle(form: _form, isSigned: true),
              const SizedBox(height: GujeukSpacing.s100),
              if (_submitError case final error?) ...[
                Text(
                  error,
                  style: GujeukTypography.bodyMd.copyWith(
                    color: GujeukColors.decorRed,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s16),
              ],
              Row(
                children: [
                  Expanded(
                    child: GujeukButton(
                      label: '다 했어요!',
                      icon: GujeukIcons.party,
                      isLoading: _isSubmitting,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
