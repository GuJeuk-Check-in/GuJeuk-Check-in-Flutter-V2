import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_submit_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_text_fields.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/submit_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/bottom.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/submit_problem_dialog.dart';

class SignUpPage extends ConsumerStatefulWidget {
  /// 이름 확인 화면에서 적은 이름. 이름 칸에 미리 채워 둡니다.
  /// 이름 확인을 건너뛴 장애 중 접수면 빈 값입니다.
  final String name;

  /// 서버와 연결이 안 돼 회원인지 확인하지 못한 친구인지.
  /// 정보를 모두 받아 기기에 저장하고, 예약 시설도 시간 없이 접수합니다.
  final bool offline;

  const SignUpPage({super.key, required this.name, this.offline = false});

  /// 웹과 같은 카드 최대 너비. 1920 화면에서 좌우 448씩 여백이 생깁니다.
  /// 고정 여백 대신 최대 너비로 잡아 작은 화면에서도 깨지지 않게 합니다.
  static const double _cardMaxWidth = 1232;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  /// 칸을 고치면 그 칸에 떠 있던 에러를 지웁니다.
  late final SignUpTextFields _fields = SignUpTextFields(
    initialName: widget.name,
    onEdited: (field) =>
        ref.read(signUpFormProvider.notifier).clearError(field),
  );

  @override
  void initState() {
    super.initState();
    ref.read(signUpFormProvider.notifier).offline = widget.offline;
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final result = await ref
        .read(signUpSubmitProvider.notifier)
        .submit(_fields.values, offline: widget.offline);
    if (!mounted) return;
    if (result is! SubmitDone) return showSubmitProblem(context, result);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationEndPage(reservation: result.reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submit = ref.watch(signUpSubmitProvider);
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
              if (widget.offline) ...[
                const SizedBox(height: GujeukSpacing.s16),
                Text(
                  '지금은 서버와 연결이 안 돼서 친구 정보를 확인하지 못했어. 아래 내용을 모두 적어줘!',
                  style: GujeukTypography.bodyMd.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
              ],
              const SizedBox(height: GujeukSpacing.s40),
              Middle(fields: _fields),
              const SizedBox(height: GujeukSpacing.s100),
              Bottom(onSubmit: _onSubmit, isSubmitting: submit.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
