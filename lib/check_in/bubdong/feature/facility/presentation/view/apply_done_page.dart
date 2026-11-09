import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';

/// 시설 이용 신청을 마친 뒤 보여주는 화면 (Figma 신청 완료)
class ApplyDonePage extends StatelessWidget {
  const ApplyDonePage({super.key, this.lastFacility});

  final Facility? lastFacility; // 마지막에 쓴 신청서 (신청서 없이 왔으면 null)

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BubdongPageHeader(
            // TODO: 여러 장 썼을 때 제목은 디자이너 답변 후 확정
            title: lastFacility == null
                ? '이용 신청서'
                : '${lastFacility!.label} 이용 신청서',
            subtitle: '신청을 완료했습니다. 처음으로 돌아가주세요',
          ),
          // TODO: Figma 간격 확인 전이라 다른 신청서와 같은 값 사용
          const SizedBox(height: BubdongLayout.applyHeaderToCardGap),
          BubdongContentCard(
            width: BubdongLayout.applyDoneCardWidth,
            padding: const EdgeInsets.all(BubdongSpacing.s64),
            borderRadius: BubdongRadius.r48All,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/bubdong/icon_circle_check.svg', // 색은 SVG 파일 안에 들어 있음 (MainColor)
                  width: BubdongLayout.applyDoneIconSize,
                  height: BubdongLayout.applyDoneIconSize,
                ),
                const SizedBox(height: BubdongSpacing.s20),
                Text(
                  '시설 이용 신청이 끝났어',
                  style: BubdongTypography.titleLg.copyWith(
                    color: BubdongColors.textAccent,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s8),
                Text(
                  '우리 시설을 바로 이용해도 좋아~!',
                  style: BubdongTypography.headingMd.copyWith(
                    color: BubdongColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BubdongLayout.applyDoneButtonGap),
                BubdongButton(
                  label: '다했어요!',
                  variant: BubdongButtonVariant.primaryLarge,
                  // 홈(진입 화면)으로 돌아감
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
