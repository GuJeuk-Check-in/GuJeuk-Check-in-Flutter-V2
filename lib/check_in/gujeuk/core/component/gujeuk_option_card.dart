import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// [GujeukOptionCard] 아래 3D 그림자 색.
enum GujeukOptionAccent { orange, teal, indigo }

/// Figma `Option Card` · 선택 카드 (방문 목적·시설, 나이대).
/// 나이 카드는 [icon]에 `GujeukIcons.age*`를 지정합니다.
class GujeukOptionCard extends StatelessWidget {
  final String label;
  final GujeukOptionAccent accent;
  final bool selected;
  final GujeukIcons? icon;
  final VoidCallback? onTap;

  /// 지금 고를 수 없는 카드. 회색으로 그리고 [disabledLabel]을 아래에 띄웁니다.
  final bool disabled;
  final String disabledLabel;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  /// 최소 높이. null이면 Figma 기본 높이(168)를 씁니다.
  /// 글자가 커지면 그만큼 늘어납니다.
  final double? height;

  const GujeukOptionCard({
    super.key,
    required this.label,
    this.accent = GujeukOptionAccent.orange,
    this.selected = false,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.disabledLabel = '예약 불가',
    this.width = double.infinity,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final (selectedBg, borderColor, shadow, shadowStrong) = switch (accent) {
      GujeukOptionAccent.orange => (
        GujeukColors.bgSelectedOrange,
        GujeukColors.borderAccentOrange,
        GujeukShadows.orange3d,
        GujeukShadows.orange3dStrong,
      ),
      GujeukOptionAccent.teal => (
        GujeukColors.bgSelected,
        GujeukColors.borderSelected,
        GujeukShadows.teal3d,
        GujeukShadows.teal3dStrong,
      ),
      GujeukOptionAccent.indigo => (
        GujeukColors.bgSelectedIndigo,
        GujeukColors.borderAccentIndigo,
        GujeukShadows.indigo3d,
        GujeukShadows.indigo3dStrong,
      ),
    };

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: height ?? 168),
        // 세로 가운데 정렬은 Column이 맡으므로 위아래 여백은 최소한만 둡니다.
        padding: const EdgeInsets.symmetric(
          horizontal: GujeukSpacing.s26,
          vertical: GujeukSpacing.s16,
        ),
        decoration: BoxDecoration(
          color: disabled
              ? GujeukColors.bgDisabled
              : selected
              ? selectedBg
              : GujeukColors.bgField,
          borderRadius: GujeukRadius.xlAll,
          border: selected && !disabled
              ? Border.all(color: borderColor, width: 4)
              : null,
          boxShadow: disabled
              ? null
              : selected
              ? shadowStrong
              : shadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              GujeukIcon(icon!),
              const SizedBox(height: GujeukSpacing.s8),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: GujeukTypography.bodySm.copyWith(
                color: disabled
                    ? GujeukColors.textDisabled
                    : GujeukColors.textPrimary,
              ),
            ),
            if (disabled) ...[
              const SizedBox(height: GujeukSpacing.s2),
              Text(
                disabledLabel,
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
