import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/gujeuk_signup_field.dart';

class Bottom extends StatelessWidget {
  final SignUpFormController form;
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  /// 제출 요청이 실패했을 때 버튼 위에 띄울 문구.
  final String? submitError;

  const Bottom({
    super.key,
    required this.form,
    this.onSubmit,
    this.isSubmitting = false,
    this.submitError,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) {
        final agreementError = form.agreementError;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('개인정보 수집 및 이용 동의',style: GujeukTypography.bodyLg,),
                const SizedBox(width: GujeukSpacing.s12,),
                Checkbox(
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    return states.contains(WidgetState.selected)
                        ? GujeukColors.decorSky
                        : Colors.white;
                  }),
                  checkColor: Colors.white,
                  side: const BorderSide(color: GujeukColors.borderSubtle, width: 2),
                  value: form.agreed,
                  onChanged: (value) => form.setAgreed(value ?? false),
                ),
              ],
            ),
            const SizedBox(height: GujeukSpacing.s12,),
            Text('(이름,생년월일,연락처,방문 목적,성별,cctv 촬영,거주지)',style: GujeukTypography.bodyMd,),
            if (agreementError != null) ...[
              const SizedBox(height: GujeukSpacing.s16),
              SignUpErrorText(agreementError),
            ],
            const SizedBox(height: GujeukSpacing.s40,),
            if (submitError case final error?) ...[
              SignUpErrorText(error),
              const SizedBox(height: GujeukSpacing.s16),
            ],
            Row(
              children: [
                Expanded(
                  child: GujeukButton(
                    label: '다 했어요!',
                    icon: GujeukIcons.party,
                    isLoading: isSubmitting,
                    onPressed: onSubmit,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
