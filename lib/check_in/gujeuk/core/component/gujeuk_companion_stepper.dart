import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_gender_toggle.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// Figma `Companion Stepper` · 동행인 수 (남/여). − 는 0에서 비활성.
class GujeukCompanionStepper extends StatelessWidget {
  final GujeukGender gender;
  final int count;
  final ValueChanged<int>? onChanged;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukCompanionStepper({
    super.key,
    required this.gender,
    required this.count,
    this.onChanged,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 104,
      padding: const EdgeInsets.symmetric(
        horizontal: GujeukSpacing.s40,
        vertical: GujeukSpacing.s24,
      ),
      decoration: const BoxDecoration(
        color: GujeukColors.bgField,
        borderRadius: GujeukRadius.fullAll,
        boxShadow: GujeukShadows.blue3dSoft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GujeukIcon(gender.icon),
              const SizedBox(width: GujeukSpacing.s16),
              Text(
                gender.label,
                style: GujeukTypography.bodyMdMedium.copyWith(
                  color: GujeukColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _StepButton(
                icon: GujeukIcons.minus,
                background: GujeukColors.bgSurface,
                onTap: count > 0 && onChanged != null
                    ? () => onChanged!(count - 1)
                    : null,
              ),
              const SizedBox(width: GujeukSpacing.s32),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 24),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: GujeukTypography.headingMd.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
              ),
              const SizedBox(width: GujeukSpacing.s32),
              _StepButton(
                icon: GujeukIcons.plus,
                background: GujeukColors.actionPrimary,
                onTap: onChanged == null ? null : () => onChanged!(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final GujeukIcons icon;
  final Color background;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.background, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: GujeukRadius.fullAll,
          boxShadow: GujeukShadows.blue3d6,
        ),
        child: GujeukIcon(icon),
      ),
    );
  }
}
