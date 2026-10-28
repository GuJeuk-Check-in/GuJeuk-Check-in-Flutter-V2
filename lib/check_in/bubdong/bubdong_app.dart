import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_facility_card.dart';

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
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                BubdongFacilityCard(title: '인터넷', subtitle: '신청서 작성'),
                BubdongFacilityCard(
                  title: '탁구',
                  subtitle: '신청서 작성',
                  color: BubdongCardColor.mint,
                  status: BubdongCardStatus.selected,
                ),
                BubdongFacilityCard(
                  title: '보드게임',
                  detail: '남은 시간 : 00분',
                  color: BubdongCardColor.blue,
                  status: BubdongCardStatus.unavailable,
                ),
                BubdongFacilityCard(
                  title: '휴식',
                  color: BubdongCardColor.pink,
                  status: BubdongCardStatus.completed,
                ),
                BubdongFacilityCard(
                  title: '방카',
                  detail: '2번 좌석 / 남은 시간 : 00분',
                  status: BubdongCardStatus.inUse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}