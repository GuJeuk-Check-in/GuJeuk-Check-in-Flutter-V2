import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_basic_page.dart';
class BubdongApp extends StatelessWidget {
  const BubdongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '법동 체크인',
      debugShowCheckedModeBanner: false,
      theme: BubdongTheme.light,
      home: const SignupBasicPage(),
    );
  }
}