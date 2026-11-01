import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/phone_check_dialog.dart';

class ReservationPage extends ConsumerStatefulWidget {
  final String name;

  /// 이름 확인에서 받은 회원 id. 방문 기록을 남길 때 씁니다.
  final int userId;

  const ReservationPage({super.key, required this.name, required this.userId});

  static const double _cardMaxWidth = 1232;

  @override
  ConsumerState<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends ConsumerState<ReservationPage> {
  late final ReservationRepository _reservations = ref.read(
    reservationRepositoryProvider,
  );

  /// 요청하는 동안 버튼을 다시 눌러도 무시합니다.
  bool _isSubmitting = false;
  String? _submitError;

  SignUpFormController get _form => ref.read(signUpFormProvider.notifier);

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
        await _checkIn();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 예약이 필요 없는 목적은 방문 기록만 남기고 완료 화면으로 갑니다.
  Future<void> _checkIn() async {
    final form = ref.read(signUpFormProvider);
    try {
      await ref
          .read(checkInRepositoryProvider)
          .checkIn(
            userId: widget.userId,
            purpose: form.purpose!,
            maleCount: form.maleCount,
            femaleCount: form.femaleCount,
          );
    } catch (_) {
      if (mounted) setState(() => _submitError = '기록하지 못했어요. 다시 눌러주세요');
      return;
    }
    if (mounted) _goToEnd(null);
  }

  /// 처음엔 전화번호 없이 보내고, 같은 이름의 회원이 있다는 409가 오면
  /// 예약 문자를 받을 번호를 받아 같은 내용으로 한 번 더 보냅니다.
  Future<void> _reserve({String? phone}) async {
    final form = ref.read(signUpFormProvider);
    try {
      await _reservations.reserve(
        name: widget.name,
        phone: phone == null ? null : PhoneNumberFormatter.digitsOf(phone),
        purpose: form.purpose!,
        startTime: form.time!,
        maleCount: form.maleCount,
        femaleCount: form.femaleCount,
      );
    } on DuplicateNameException {
      if (!mounted) return;
      final entered = await PhoneCheckDialog.show(context);
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
        purpose: form.purpose!,
        phone: phone ?? '',
        startTime: form.time!,
        maleCount: form.maleCount,
        femaleCount: form.femaleCount,
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
              const Middle(),
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
