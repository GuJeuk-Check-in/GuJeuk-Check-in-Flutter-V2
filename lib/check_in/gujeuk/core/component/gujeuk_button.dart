import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

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

  /// 기본은 라벨 + 패딩 크기에 맞춥니다. 부모를 채우려면 `double.infinity`를 넘기세요.
  final double? width;

  /// 버튼 높이. 넘기지 않으면 variant의 기본 높이를 씁니다.
  final double? height;

  /// 안쪽 여백. 넘기지 않으면 variant의 기본 좌우 패딩을 씁니다.
  final EdgeInsetsGeometry? padding;

  /// 요청 중이면 아이콘 자리에 스피너를 띄우고 눌러도 무시합니다.
  final bool isLoading;

  const GujeukButton({
    super.key,
    required this.label,
    this.variant = GujeukButtonVariant.primaryLarge,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _ButtonSpec.of(variant);

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height ?? spec.height,
        padding: padding ?? EdgeInsets.symmetric(horizontal: spec.paddingX),
        decoration: BoxDecoration(
          color: spec.background,
          borderRadius: spec.radius,
          border: spec.borderColor == null
              ? null
              : Border.all(color: spec.borderColor!, width: 4),
          boxShadow: spec.shadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: spec.textStyle.copyWith(color: spec.textColor)),
            if (isLoading) ...[
              SizedBox(width: spec.gap),
              // 아이콘과 같은 크기로 잡아 버튼 크기가 흔들리지 않게 합니다.
              SizedBox.square(
                dimension: icon?.size ?? 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: spec.textColor,
                ),
              ),
            ] else if (icon != null) ...[
              SizedBox(width: spec.gap),
              GujeukIcon(icon!),
            ],
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
