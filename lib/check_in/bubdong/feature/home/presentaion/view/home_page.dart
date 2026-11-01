import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bubdong/bubdong_logo.png', height: 144),
          const SizedBox(height: 109),
          Text(
            '시설을 이용하려면 아래 버튼을 눌러줘',
            style: BubdongTypography.h2.copyWith(
              color: BubdongColors.textAccent,
            ),
          ),
          const SizedBox(height: BubdongSpacing.s40),
          SizedBox(
            width: 802,
            child: Row(
              children: [
                Expanded(
                  child: BubdongButton(
                    label: '이용 대장 조회하기',
                    icon: SvgPicture.asset(
                      'assets/icons/bubdong/icon_ledger.svg',
                      width: 36,
                      height: 36,
                    ),
                    onPressed: () {},
                    variant: BubdongButtonVariant.tone,
                  ),
                ),
                const SizedBox(width: BubdongSpacing.s20),
                Expanded(
                  child: BubdongButton(
                    label: '방문 기록 남기기',
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/bubdong/icon_visit.svg',
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}