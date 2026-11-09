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

  static const _height = 128.0;

  /// 80분 → '1시간 20분'
  String get _usedTimeText => '${usedTime.inHours}시간 ${usedTime.inMinutes % 60}분';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _height,
        padding: const EdgeInsets.only(left: BubdongSpacing.s40, right: 60),
        decoration: BoxDecoration(
          color: BubdongColors.bgSurface,
          borderRadius: BubdongRadius.r30All,
          border: Border.all(color: BubdongColors.borderCard, width: 1),
        ),
        child: Row(
          children: [
            // 왼쪽: 이름
            Text(name, style: BubdongTypography.h3.copyWith(color: BubdongColors.textPrimary)),
            const SizedBox(width: BubdongSpacing.s40),

            // 가운데: 선택한 이용대장
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선택한 이용대장',
                  style: BubdongTypography.captionSm.copyWith(color: BubdongColors.textPlaceholder),
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
                  style: BubdongTypography.captionSm.copyWith(color: BubdongColors.textPlaceholder),
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
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 9),
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