import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_basic_page.dart';

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
              maxWidth: BubdongLayout.homeActionRowWidth,
            ),
            child: Row(
              children: [
                // 이용 대장 조회
                Expanded(
                  child: BubdongButton(
                    label: '이용 대장 조회하기',
                    variant: BubdongButtonVariant.toneMedium,
                    icon: SvgPicture.asset(
                      'assets/icons/bubdong/icon_ledger.svg',
                      width: 36,
                      height: 36,
                    ),
                    onPressed: () {}, // TODO: 방명록 리스트 화면 연결
                  ),
                ),
                const SizedBox(width: BubdongSpacing.s20),

                // 아이들 방문 기록
                Expanded(
                  child: BubdongButton(
                    label: '아이들 방문 기록 남기기',
                    variant: BubdongButtonVariant.yellowMedium,
                    icon: SvgPicture.asset(
                      'assets/icons/bubdong/icon_visit.svg',
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        BubdongColors.textPrimary, // 검정 아이콘
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupBasicPage()),
                    ),
                  ),
                ),
                const SizedBox(width: BubdongSpacing.s20),

                // 어른 방문 기록
                Expanded(
                  child: BubdongButton(
                    label: '어른 방문 기록 남기기',
                    variant: BubdongButtonVariant.blueMedium,
                    icon: SvgPicture.asset(
                      'assets/icons/bubdong/icon_visit.svg',
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        BubdongColors.textOnPrimary, // 흰 아이콘
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {}, // 어른 방문 기록 화면 연결
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