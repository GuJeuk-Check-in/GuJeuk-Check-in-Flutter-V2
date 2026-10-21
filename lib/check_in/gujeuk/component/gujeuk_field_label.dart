import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

/// Figma `Field Label` · 폼 필드 위 라벨 (아이콘 + 질문).
class GujeukFieldLabel extends StatelessWidget {
  final String label;
  final GujeukIcons icon;

  const GujeukFieldLabel({
    super.key,
    required this.label,
    this.icon = GujeukIcons.rocket,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GujeukIcon(icon),
        const SizedBox(width: GujeukSpacing.s8),
        Text(
          label,
          style: GujeukTypography.bodyMd.copyWith(
            color: GujeukColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
