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

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  /// null이면 Figma 기본 높이(168)를 씁니다.
  final double? height;

  const GujeukOptionCard({
    super.key,
    required this.label,
    this.accent = GujeukOptionAccent.orange,
    this.selected = false,
    this.icon,
    this.onTap,
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
      onTap: onTap,
      child: Container(
        width: width,
        height: height ?? 168,
        padding: const EdgeInsets.all(GujeukSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? selectedBg : GujeukColors.bgField,
          borderRadius: GujeukRadius.xlAll,
          border: selected ? Border.all(color: borderColor, width: 4) : null,
          boxShadow: selected ? shadowStrong : shadow,
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
                color: GujeukColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
