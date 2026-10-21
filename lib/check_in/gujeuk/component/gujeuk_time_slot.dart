import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

/// Figma `Time Slot` · 시설 예약 시간. [reserved]면 선택할 수 없습니다.
class GujeukTimeSlot extends StatelessWidget {
  final String time;
  final bool selected;
  final bool reserved;
  final VoidCallback? onTap;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukTimeSlot({
    super.key,
    required this.time,
    this.selected = false,
    this.reserved = false,
    this.onTap,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final (background, shadow, timeColor) = reserved
        ? (GujeukColors.bgDisabled, null, GujeukColors.textDisabled)
        : selected
        ? (
            GujeukColors.actionPrimary,
            GujeukShadows.navy3dPressed,
            GujeukColors.textInverse,
          )
        : (
            GujeukColors.bgField,
            GujeukShadows.blue3d8,
            GujeukColors.textPrimary,
          );

    return GestureDetector(
      onTap: reserved ? null : onTap,
      child: Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          color: background,
          borderRadius: GujeukRadius.fullAll,
          boxShadow: shadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: GujeukTypography.bodyLg.copyWith(color: timeColor),
            ),
            if (reserved) ...[
              const SizedBox(height: GujeukSpacing.s2),
              Text(
                '예약 마감',
                style: GujeukTypography.caption.copyWith(
                  color: GujeukColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
