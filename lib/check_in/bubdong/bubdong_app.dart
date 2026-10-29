import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_facility_card.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_select_card.dart';

class BubdongApp extends StatelessWidget {
  const BubdongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '법동 체크인',
      debugShowCheckedModeBanner: false,
      theme: BubdongTheme.light,
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                BubdongSelectCard(
                  label: '남자',
                  icon: Icons.male,
                  color: BubdongCardColor.mint,
                ),
                BubdongSelectCard(
                  label: '여자',
                  icon: Icons.female,
                  color: BubdongCardColor.pink,
                  selected: true,
                ),
                BubdongSelectCard(
                  label: '친구가 데려와서',
                  icon: Icons.people_outline,
                ),
                BubdongSelectCard(
                  label: '부모님의 권유',
                  icon: Icons.family_restroom,
                  color: BubdongCardColor.mint,
                  selected: true,
                ),
                BubdongSelectCard(
                  label: '기타',
                  icon: Icons.edit,
                  color: BubdongCardColor.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}