import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// Figma `List Item` · 거주지 검색 결과.
class GujeukListItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukListItem({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 56,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s28),
        color: selected ? GujeukColors.listSelected : GujeukColors.bgSurface,
        child: Text(
          label,
          style: GujeukTypography.bodyMdMedium.copyWith(
            color: selected
                ? GujeukColors.textInverse
                : GujeukColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
