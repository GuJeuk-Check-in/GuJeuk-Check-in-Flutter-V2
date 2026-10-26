import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_field_label.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// 라벨 + 간격 + 입력 위젯을 세로로 묶습니다.
class GujeukLabeledField extends StatelessWidget {
  final String label;
  final GujeukIcons icon;
  final Widget child;

  /// [child] 아래에 띄울 에러 문구. [GujeukInput]처럼 자체 에러 표시가 없는 위젯에 씁니다.
  final String? errorText;

  const GujeukLabeledField({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GujeukFieldLabel(label: label, icon: icon),
        const SizedBox(height: GujeukSpacing.s10),
        child,
        if (errorText != null) ...[
          const SizedBox(height: GujeukSpacing.s16),
          SignUpErrorText(errorText),
        ],
      ],
    );
  }
}

/// [GujeukInput]의 에러 문구와 같은 모양의 텍스트.
class SignUpErrorText extends StatelessWidget {
  final String text;

  const SignUpErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s28),
      child: Text(
        text,
        style: GujeukTypography.bodyMd.copyWith(color: GujeukColors.decorRed),
      ),
    );
  }
}
