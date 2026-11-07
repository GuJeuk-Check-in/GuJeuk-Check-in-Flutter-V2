import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 화면 맨 위 "법동 청소년 문화센터" + 제목 (+ 설명)
class BubdongPageHeader extends StatelessWidget {
  const BubdongPageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;

  /// 제목 아래 작은 설명 (없으면 안 보임)
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '법동 청소년 문화센터',
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
        if (subtitle != null) ...[
          const SizedBox(height: BubdongSpacing.s8),
          Text(
            subtitle!,
            style: BubdongTypography.bodyLg.copyWith(
              color: BubdongColors.textPlaceholder,
            ),
          ),
        ],
      ],
    );
  }
}
