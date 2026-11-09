import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_basic_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/home/presentation/widgets/home_menu_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bubdong/bubdong_logo.png', height: 144),
          const SizedBox(height: BubdongLayout.homeLogoGap),
          Text(
            '시설을 이용하려면 아래 버튼을 눌러줘',
            style: BubdongTypography.h2.copyWith(color: BubdongColors.textAccent),
          ),
          const SizedBox(height: BubdongSpacing.s40),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: BubdongLayout.homeMenuRowWidth,
            ),
            child: Row(
              spacing: BubdongLayout.homeMenuGap, // Figma 카드 사이
              children: [
                Expanded(
                  flex: BubdongLayout.homeMenuCardFlex,
                  child: HomeMenuCard(
                    label: '이용 대장 조회하기',
                    imagePath: 'assets/images/bubdong/home_ledger.png',
                    type: HomeMenuType.ledger,
                    onTap: () {}, // TODO: 방명록 리스트 화면 연결
                  ),
                ),
                Expanded(
                  flex: BubdongLayout.homeMenuChildCardFlex,
                  child: HomeMenuCard(
                    label: '아이들 방문 기록 남기기',
                    imagePath: 'assets/images/bubdong/home_child.png',
                    type: HomeMenuType.child,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupBasicPage()),
                    ),
                  ),
                ),
                Expanded(
                  flex: BubdongLayout.homeMenuCardFlex,
                  child: HomeMenuCard(
                    label: '어른 방문 기록 남기기',
                    imagePath: 'assets/images/bubdong/home_adult.png',
                    type: HomeMenuType.adult,
                    onTap: () {}, // TODO: 어른 방문 기록 화면 연결
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
