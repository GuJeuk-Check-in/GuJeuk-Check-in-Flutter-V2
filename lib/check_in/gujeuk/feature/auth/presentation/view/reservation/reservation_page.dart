import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/base_scaffold.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/color.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/radius.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/shadow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/spacing.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/reservation_submit_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/submit_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/phone_check_dialog.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/submit_problem_dialog.dart';

class ReservationPage extends ConsumerWidget {
  final String name;

  /// 이름 확인에서 받은 회원 id. 방문 기록을 남길 때 씁니다.
  final int userId;

  const ReservationPage({super.key, required this.name, required this.userId});

  static const double _cardMaxWidth = 1232;

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    final submit = ref.read(reservationSubmitProvider.notifier);
    var result = await submit.submit(name: name, userId: userId);
    // 같은 이름의 회원이 있으면 예약 문자를 받을 번호를 받아 같은 내용으로 다시 보냅니다.
    while (result is SubmitNeedsPhone) {
      if (!context.mounted) return;
      final phone = await PhoneCheckDialog.show(context);
      // 취소하면 예약 화면에 그대로 남아 다시 누를 수 있습니다.
      if (phone == null || !context.mounted) return;
      result = await submit.retryWithPhone(name: name, phone: phone);
    }
    if (!context.mounted) return;
    if (result case SubmitDone(:final reservation)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReservationEndPage(reservation: reservation),
        ),
      );
    } else {
      await showSubmitProblem(context, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submit = ref.watch(reservationSubmitProvider);
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s100),
        child: Container(
          constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
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
              Row(
                children: [
                  Expanded(
                    child: GujeukButton(
                      label: '다 했어요!',
                      icon: GujeukIcons.party,
                      isLoading: submit.isLoading,
                      onPressed: () => _onSubmit(context, ref),
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
