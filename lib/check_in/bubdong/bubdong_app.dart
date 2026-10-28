import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_dropdown.dart';

class BubdongApp extends StatefulWidget {
  const BubdongApp({super.key});

  @override
  State<BubdongApp> createState() => _BubdongAppState();
}

class _BubdongAppState extends State<BubdongApp> {
  String? _selected; // 고른 값 기억

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
            child: BubdongDropdown(
              label: '전화번호가 뭐야?',
              hintText: '친구의 전화번호를 알려줘',
              items: const ['하나', '둘', '셋'],
              value: _selected,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ),
      ),
    );
  }
}