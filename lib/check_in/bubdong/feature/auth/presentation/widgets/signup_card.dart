import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
class SignupCard extends StatelessWidget {
  const SignupCard({
    super.key,
    required this.width,
    required this.padding,
    required this.child,
  });

  final double width;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: BubdongPalette.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: BubdongColors.borderCard, width: 4),
        boxShadow: [BubdongShadow.card],
      ),
      child: child,
    );
  }
}