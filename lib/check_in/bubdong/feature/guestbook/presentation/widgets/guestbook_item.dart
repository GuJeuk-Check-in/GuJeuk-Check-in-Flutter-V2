import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';

/// 방명록 리스트의 사람 한 명 카드
class GuestbookItem extends StatelessWidget {
  const GuestbookItem({
    super.key,
    required this.name,
    required this.usedTime,
    required this.onTap,
    required this.facilities,
  });

  final String name; // 어른은 '성인'
  final Duration usedTime;
  final VoidCallback onTap;
  final List<Facility> facilities;

  /// 이용 시간 글자
  /// 30분 → '30분', 60분 → '1시간', 80분 → '1시간 20분'
  String get _usedTimeText {
    final hours = usedTime.inHours;
    final minutes = usedTime.inMinutes % 60;
    if (hours == 0) return '$minutes분'; // 1시간 미만
    if (minutes == 0) return '$hours시간'; // 딱 나누어떨어짐
    return '$hours시간 $minutes분';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 카드 빈 곳을 눌러도 동작
      child: Container(
        height: BubdongLayout.guestbookCardHeight,
        padding: BubdongLayout.guestbookCardPadding,
        decoration: BoxDecoration(
          color: BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r30All,
          border: Border.all(color: BubdongColors.borderGuestbookCard, width: 1),
        ),
        child: Row(
          children: [
            // 왼쪽: 이름
            // 칸 너비를 맞춰 이름이 짧아도 칩이 같은 자리에서 시작 (긴 이름은 칸보다 넓어짐)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: BubdongLayout.guestbookNameWidth),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: BubdongTypography.guestName.copyWith(color: BubdongColors.textGuestName),
              ),
            ),
            const SizedBox(width: BubdongSpacing.s40),

            // 가운데: 선택한 이용대장
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선택한 이용대장',
                  style: BubdongTypography.captionSm.copyWith(color: BubdongColors.textCaption),
                ),
                const SizedBox(height: BubdongSpacing.s8),
                Row(
                  children: [
                    for (final facility in facilities) ...[
                      _FacilityTag(label: facility.label),
                      if (facility != facilities.last) const SizedBox(width: BubdongSpacing.s12),
                    ],
                  ],
                ),
              ],
            ),

            // 남은 공간 → 시간을 오른쪽 끝으로
            const Spacer(),

            // 오른쪽: 이용한 시간
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '이용한 시간',
                  style: BubdongTypography.captionSm.copyWith(color: BubdongColors.textCaption),
                ),
                Text(
                  _usedTimeText,
                  style: BubdongTypography.valueLg.copyWith(color: BubdongColors.textAccentDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 이용대장 이름 칩
class _FacilityTag extends StatelessWidget {
  const _FacilityTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BubdongLayout.guestbookTagPadding,
      decoration: BoxDecoration(
        color: BubdongColors.brandSubtle,
        borderRadius: BubdongRadius.r30All,
      ),
      child: Text(
        label,
        style: BubdongTypography.tagLabel.copyWith(color: BubdongColors.textAccentDark),
      ),
    );
  }
}