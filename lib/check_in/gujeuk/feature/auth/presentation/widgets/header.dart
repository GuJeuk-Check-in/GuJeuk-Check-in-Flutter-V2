import 'package:flutter/cupertino.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          // 아이콘(24)보다 넉넉한 터치 영역을 줍니다.
          child: const SizedBox(
            width: GujeukSpacing.s48,
            height: GujeukSpacing.s48,
            child: Center(child: GujeukIcon(GujeukIcons.arrowLeft)),
          ),
        ),
        // 남은 너비만 쓰고, 좁으면 제목을 한 줄 그대로 줄여서 넘치지 않게 합니다.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  '구즉 청소년문화의 집에 온걸 환영해~!',
                  style: GujeukTypography.titleLg.copyWith(
                    color: GujeukColors.iconBrand,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s12),
                Text(
                  '시설을 이용하려면 작성해줘',
                  style: GujeukTypography.headingMd.copyWith(
                    color: GujeukColors.iconBrand,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 왼쪽 뒤로가기 영역과 같은 너비를 비워 제목이 화면 가운데에 오게 합니다.
        const SizedBox(width: GujeukSpacing.s48),
      ],
    );
  }
}
