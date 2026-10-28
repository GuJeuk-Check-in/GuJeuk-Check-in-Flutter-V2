import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_input.dart';

class BubdongApp extends StatelessWidget {
  const BubdongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '법동 체크인',
      debugShowCheckedModeBanner: false,
      theme: BubdongTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 460,
            child: BubdongInput(
              label: '안녕',
              hintText: '전화번호 입력해줘',
              validator: (value) => value == '1234' ? null : '틀렸어.',
            ),
          ),
        ),
      ),
    );
  }
}
