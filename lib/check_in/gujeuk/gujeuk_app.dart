import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/sign_up_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

class GujeukApp extends StatelessWidget {
  const GujeukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구즉 체크인',
      theme: GujeukTheme.light,
      debugShowCheckedModeBanner: false,
      home: const SignUpPage(),
    );
  }
}
