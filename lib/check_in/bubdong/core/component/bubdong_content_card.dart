import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 흰 바탕 큰 카드 (회원가입·신청서 화면 가운데 카드)
class BubdongContentCard extends StatelessWidget {
  const BubdongContentCard({
    super.key,
    required this.width,
    required this.padding,
    required this.child,
    this.height,
  });

  final double width;
  final EdgeInsets padding;
  final Widget child;
  final double? height; // 없으면 내용 높이만큼

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: BubdongColors.bgSurface,
        borderRadius: BubdongRadius.r32All,
        border: Border.all(color: BubdongColors.borderCard, width: 4),
        boxShadow: [BubdongShadow.card],
      ),
      child: child,
    );
  }
}
