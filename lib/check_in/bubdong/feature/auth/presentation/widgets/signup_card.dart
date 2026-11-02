import 'package:flutter/material.dart';

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
      child: child,
    );
  }
}