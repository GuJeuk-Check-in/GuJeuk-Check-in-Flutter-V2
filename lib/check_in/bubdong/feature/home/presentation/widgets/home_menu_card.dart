import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 진입 화면 카드 종류
enum HomeMenuType {
  /// 이용 대장 조회하기
  ledger,

  /// 아이들 방문 기록 남기기
  child,

  /// 어른 방문 기록 남기기
  adult,
}

/// 진입 화면의 그림 카드 (Figma 진입 화면 카드, 너비는 부모를 채움)
class HomeMenuCard extends StatelessWidget {
  const HomeMenuCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.type,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final HomeMenuType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spec = _HomeMenuSpec.of(type);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 카드 빈 곳을 눌러도 동작
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(BubdongSpacing.s40),
        decoration: BoxDecoration(
          borderRadius: BubdongRadius.r40All,
          border: Border.all(color: spec.border, width: 4),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: BubdongLayout.homeMenuImageWidth,
              height: BubdongLayout.homeMenuImageHeight,
            ),
            const SizedBox(height: BubdongSpacing.s40),
            Text(
              label,
              style: BubdongTypography.cardTitle.copyWith(color: spec.text),
            ),
          ],
        ),
      ),
    );
  }
}

// 카드 종류별 색 묶음
class _HomeMenuSpec {
  const _HomeMenuSpec({required this.border, required this.text});

  final Color border;
  final Color text;

  static _HomeMenuSpec of(HomeMenuType type) {
    switch (type) {
      case HomeMenuType.ledger:
        return const _HomeMenuSpec(
          border: BubdongColors.homeMenuLedgerBorder,
          text: BubdongColors.textAccentDark,
        );
      case HomeMenuType.child:
        return const _HomeMenuSpec(
          border: BubdongColors.homeMenuChildBorder,
          text: BubdongColors.textPrimary,
        );
      case HomeMenuType.adult:
        return const _HomeMenuSpec(
          border: BubdongColors.homeMenuAdultBorder,
          text: BubdongColors.textPrimary,
        );
    }
  }
}
