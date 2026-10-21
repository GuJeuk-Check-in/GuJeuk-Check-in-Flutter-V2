import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

/// Figma `Button`의 Type × Size 조합.
enum GujeukButtonVariant {
  /// Primary / Large · 폼 제출 (다 했어요!)
  primaryLarge,

  /// Primary / Medium · 모달 확인 버튼
  primaryMedium,

  /// Neutral / Medium · 모달 취소 버튼
  neutralMedium,

  /// Landing / XLarge · 첫 화면 CTA
  landing,

  /// Landing Outline / XLarge · 첫 화면 보조 CTA
  landingOutline,
}

class GujeukButton extends StatelessWidget {
  final String label;
  final GujeukButtonVariant variant;
  final VoidCallback? onPressed;

  /// 라벨 오른쪽 아이콘. Figma에서는 Primary / Large에만 있습니다 (기본 party).
  final GujeukIcons? icon;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukButton({
    super.key,
    required this.label,
    this.variant = GujeukButtonVariant.primaryLarge,
    this.onPressed,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _ButtonSpec.of(variant);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: spec.height,
        padding: EdgeInsets.symmetric(horizontal: spec.paddingX),
        decoration: BoxDecoration(
          color: spec.background,
          borderRadius: spec.radius,
          border: spec.borderColor == null
              ? null
              : Border.all(color: spec.borderColor!, width: 4),
          boxShadow: spec.shadows,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: spec.textStyle.copyWith(color: spec.textColor)),
            if (icon != null) ...[SizedBox(width: spec.gap), GujeukIcon(icon!)],
          ],
        ),
      ),
    );
  }
}

class _ButtonSpec {
  final double height;
  final double paddingX;
  final double gap;
  final BorderRadius radius;
  final Color background;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final TextStyle textStyle;
  final Color textColor;

  const _ButtonSpec({
    required this.height,
    required this.paddingX,
    required this.gap,
    required this.radius,
    required this.background,
    this.borderColor,
    this.shadows,
    required this.textStyle,
    required this.textColor,
  });

  static _ButtonSpec of(GujeukButtonVariant variant) {
    switch (variant) {
      case GujeukButtonVariant.primaryLarge:
        return const _ButtonSpec(
          height: 96,
          paddingX: GujeukSpacing.s64,
          gap: GujeukSpacing.s16,
          radius: GujeukRadius.fullAll,
          background: GujeukColors.actionPrimary,
          shadows: GujeukShadows.blue3d10,
          textStyle: GujeukTypography.headingMd,
          textColor: GujeukColors.textInverse,
        );
      case GujeukButtonVariant.primaryMedium:
        return const _ButtonSpec(
          height: 56,
          paddingX: GujeukSpacing.s40,
          gap: GujeukSpacing.s8,
          radius: GujeukRadius.fullAll,
          background: GujeukColors.actionPrimary,
          textStyle: GujeukTypography.bodyLg,
          textColor: GujeukColors.textInverse,
        );
      case GujeukButtonVariant.neutralMedium:
        return const _ButtonSpec(
          height: 56,
          paddingX: GujeukSpacing.s40,
          gap: GujeukSpacing.s8,
          radius: GujeukRadius.fullAll,
          background: GujeukColors.bgNeutral,
          textStyle: GujeukTypography.bodyLg,
          textColor: GujeukColors.textTertiary,
        );
      case GujeukButtonVariant.landing:
        return const _ButtonSpec(
          height: 112,
          paddingX: GujeukSpacing.s40,
          gap: 0,
          radius: GujeukRadius.xxlAll,
          background: GujeukColors.actionLanding,
          shadows: GujeukShadows.glowSky,
          textStyle: GujeukTypography.headingLg,
          textColor: GujeukColors.textInverse,
        );
      case GujeukButtonVariant.landingOutline:
        return const _ButtonSpec(
          height: 112,
          paddingX: GujeukSpacing.s40,
          gap: 0,
          radius: GujeukRadius.xxlAll,
          background: GujeukColors.bgSurface,
          borderColor: GujeukColors.borderLanding,
          shadows: GujeukShadows.glowSkySoft,
          textStyle: GujeukTypography.headingLg,
          textColor: GujeukColors.textLanding,
        );
    }
  }
}
