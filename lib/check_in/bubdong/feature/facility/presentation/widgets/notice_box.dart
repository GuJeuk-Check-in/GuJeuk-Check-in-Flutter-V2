import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 신청서 카드 안 주황 안내 박스 (Figma 940×130, 모서리 10)
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    final style = BubdongTypography.notice.copyWith(
      color: BubdongColors.textNotice,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BubdongSpacing.s24,
        vertical: BubdongSpacing.s28,
      ),
      decoration: const BoxDecoration(
        color: BubdongColors.bgNotice,
        borderRadius: BubdongRadius.r10All,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: BubdongSpacing.s12, // Figma 줄 사이 간격
        children: [
          Text('신청서를 작성한 다음', style: style),
          Text('개인 이용대장 화면에서 ‘이용 시작’을 눌러주세요.', style: style),
        ],
      ),
    );
  }
}
