import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 카드 색 (Figma: 주황 인터넷·방카·근로장학생 / 민트 탁구·노래방 / 파랑 보드게임·청운위·기타 / 분홍 휴식·동아리)
enum BubdongCardColor { orange, mint, blue, pink }

/// 시설 카드 상태 (Figma Property 1 이름)
enum BubdongCardStatus {
  normal, // Default
  selected, // Touched
  unavailable, // Disabled: 자리 없음 + 남은 시간
  completed, // Complete: 민트 고정 + 체크 그림
  inUse, // inUse: 주황 고정 + 손 그림 + 파란 뱃지
}

/// 카드 색 묶음 (시설 카드·선택 카드가 같이 씀)
extension BubdongCardColorX on BubdongCardColor {
  // 기본 배경
  Color get tint => switch (this) {
        BubdongCardColor.orange => BubdongColors.cardOrangeBg,
        BubdongCardColor.mint => BubdongColors.cardMintBg,
        BubdongCardColor.blue => BubdongColors.cardBlueBg,
        BubdongCardColor.pink => BubdongColors.cardPinkBg,
      };

  // 아래 그림자
  Color get shadow => switch (this) {
        BubdongCardColor.orange => BubdongColors.cardOrangeShadow,
        BubdongCardColor.mint => BubdongColors.cardMintShadow,
        BubdongCardColor.blue => BubdongColors.cardBlueShadow,
        BubdongCardColor.pink => BubdongColors.cardPinkShadow,
      };

  // 선택됐을 때 테두리
  Color get border => switch (this) {
        BubdongCardColor.orange => BubdongColors.cardOrangeBorder,
        BubdongCardColor.mint => BubdongColors.cardMintBorder,
        BubdongCardColor.blue => BubdongColors.cardBlueBorder,
        BubdongCardColor.pink => BubdongColors.cardPinkBorder,
      };

  // 선택 카드 아이콘·테두리
  Color get accent => switch (this) {
        BubdongCardColor.orange => BubdongColors.cardOrangeAccent,
        BubdongCardColor.mint => BubdongColors.cardMintAccent,
        BubdongCardColor.blue => BubdongColors.cardBlueAccent,
        BubdongCardColor.pink => BubdongColors.cardPinkAccent,
      };
}

class BubdongFacilityCard extends StatelessWidget {
  const BubdongFacilityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.remainingMinutes,
    this.color = BubdongCardColor.orange,
    this.status = BubdongCardStatus.normal,
    this.onTap,
  });

  final String title; // 시설 이름
  final String? subtitle; // 예: 신청서 작성 (기본·선택됨에서만 보임)
  final int? remainingMinutes; // 자리 없음일 때 남은 시간(분)
  final BubdongCardColor color;
  final BubdongCardStatus status;
  final VoidCallback? onTap; // 자리 없음이면 눌리지 않음

  @override
  Widget build(BuildContext context) {
    final spec = _CardSpec.of(color, status);

    return GestureDetector(
      onTap: status == BubdongCardStatus.unavailable ? null : onTap,
      child: Container(
        width: double.infinity,
        height: BubdongLayout.facilityCardHeight,
        clipBehavior: Clip.antiAlias, // Figma: 넘친 콘텐츠 숨기기
        decoration: BoxDecoration(
          color: spec.background,
          borderRadius: BubdongRadius.r30All,
          border: spec.border == null
              ? null
              : Border.all(color: spec.border!, width: 4),
          boxShadow: [
            if (spec.shadow != null)
              BoxShadow(color: spec.shadow!, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (spec.iconAsset != null)
              SvgPicture.asset(
                spec.iconAsset!, // 투명도는 SVG 파일 안에 들어 있음
                width: BubdongLayout.facilityCardIconSize,
                height: BubdongLayout.facilityCardIconSize,
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: BubdongSpacing.s6, // 이름과 아래 내용 사이
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: BubdongTypography.cardTitle.copyWith(
                    color: spec.titleColor,
                  ),
                ),
                ..._buildBottom(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 이름 아래에 오는 글자·뱃지 (상태마다 다름)
  List<Widget> _buildBottom() {
    switch (status) {
      case BubdongCardStatus.normal:
      case BubdongCardStatus.selected:
        if (subtitle == null) return [];
        return [
          Text(
            subtitle!,
            style: BubdongTypography.bodyMd.copyWith(
              color: BubdongColors.textCardSubtitle,
            ),
          ),
        ];
      case BubdongCardStatus.unavailable:
        final unavailableStyle = BubdongTypography.bodyMd.copyWith(
          color: BubdongColors.textCardUnavailable,
        );
        return [
          Column(
            children: [
              if (remainingMinutes != null)
                Text(
                  '남은 시간 : ${remainingMinutes!.toString().padLeft(2, '0')}분',
                  style: unavailableStyle,
                ),
              Text('자리 없음', style: unavailableStyle),
            ],
          ),
        ];
      case BubdongCardStatus.completed:
        // Figma 화면: 뱃지 없이 주황 글자 (Body3 20/160, MainColor) + 노란 외곽선 바깥 1
        return [
          Stack(
            children: [
              // 외곽선: 선 굵기 2를 글자 가운데에 그리고 위에 채운 글자를 덮어 바깥 1만 보이게 함
              Text(
                '이용 완료',
                style: BubdongTypography.bodyMd.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = BubdongColors.borderCardCompletedText,
                ),
              ),
              Text(
                '이용 완료',
                style: BubdongTypography.bodyMd.copyWith(
                  color: BubdongColors.textCardCompleted,
                ),
              ),
            ],
          ),
        ];
      case BubdongCardStatus.inUse:
        return [
          const _CardBadge(
            label: '이용 중',
            background: BubdongColors.cardInUseBadgeBg,
            textColor: BubdongColors.cardInUseBadgeText,
          ),
        ];
    }
  }
}

/// 이용 완료·이용 중 뱃지
class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BubdongSpacing.s12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BubdongRadius.r30All,
      ),
      child: Text(
        label,
        style: BubdongTypography.bodyMd.copyWith(color: textColor),
      ),
    );
  }
}

/// 상태별 카드 모양 값
class _CardSpec {
  const _CardSpec({
    required this.background,
    this.border,
    this.shadow,
    this.titleColor = BubdongColors.textCardTitle,
    this.iconAsset,
  });

  final Color background;
  final Color? border; // 없으면 테두리 없음
  final Color? shadow; // 없으면 그림자 없음
  final Color titleColor;
  final String? iconAsset; // 가운데 뒤에 깔리는 그림

  static _CardSpec of(BubdongCardColor color, BubdongCardStatus status) {
    switch (status) {
      // Figma Default: 연한 배경 + 아래 그림자
      case BubdongCardStatus.normal:
        return _CardSpec(background: color.tint, shadow: color.shadow);
      // Figma Touched: 흰 배경 + 색 테두리 + 아래 그림자
      case BubdongCardStatus.selected:
        return _CardSpec(
          background: BubdongColors.cardSelectedBg,
          border: color.border,
          shadow: color.shadow,
        );
      // Figma Disabled: 회색 배경, 그림자 없음
      case BubdongCardStatus.unavailable:
        return const _CardSpec(
          background: BubdongColors.cardUnavailableBg,
          titleColor: BubdongColors.textDisabled,
        );
      // Figma 화면 이용 완료: 민트 배경 + 주황 테두리 + 민트 그림자 + 체크 그림
      case BubdongCardStatus.completed:
        return const _CardSpec(
          background: BubdongColors.cardCompletedBg,
          border: BubdongColors.cardCompletedBorder,
          shadow: BubdongColors.cardCompletedShadow,
          iconAsset: 'assets/icons/bubdong/icon_card_check.svg',
        );
      // Figma inUse: 카드 색과 상관없이 주황
      case BubdongCardStatus.inUse:
        return const _CardSpec(
          background: BubdongColors.cardInUseBg,
          border: BubdongColors.cardInUseBorder,
          iconAsset: 'assets/icons/bubdong/icon_card_hand.svg',
        );
    }
  }
}
