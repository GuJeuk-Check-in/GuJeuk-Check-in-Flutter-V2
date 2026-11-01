import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({
    super.key,
    required this.title,
    required this.currentStep,
  });

  final String title;
  final int currentStep;
  static const _steps = ['기본 정보', '추가 정보', '개인정보 동의'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "법동 청소년 문화센터",
          style: BubdongTypography.bodyMd.copyWith(
            color: BubdongColors.textPlaceholder,
          ),
        ),
        const SizedBox(height: BubdongSpacing.s24),
        Text(
          title,
          style: BubdongTypography.h2.copyWith(
            color: BubdongColors.textPrimary,
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              _buildStep(i),
              if (i < _steps.length - 1) const SizedBox(width: 111),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStep(int i) {
    final isCurrent = i + 1 == currentStep;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? BubdongColors.brandPrimary
                : BubdongPalette.gray100,
          ),
          child: Text(
            '${i + 1}',
            style: BubdongTypography.subtitle.copyWith(
              color: BubdongPalette.white,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Text(
          _steps[i],
          style: BubdongTypography.subtitle.copyWith(
            color: isCurrent
                ? BubdongColors.textAccentDark
                : BubdongColors.textPlaceholder,
          ),
        ),
      ],
    );
  }
}
