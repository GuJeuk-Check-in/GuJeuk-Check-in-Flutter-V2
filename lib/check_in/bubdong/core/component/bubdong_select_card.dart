import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_facility_card.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class BubdongSelectCard extends StatelessWidget {
  const BubdongSelectCard({
    super.key,
    required this.label,
    required this.icon,
    this.color = BubdongCardColor.orange,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final BubdongCardColor color; // 시설 카드와 같은 색 묶음 사용
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: BubdongSpacing.s12,
          vertical: BubdongSpacing.s16,
        ),
        decoration: BoxDecoration(
          // 선택됨: 흰 배경 + 색 테두리 / 기본: 연한 배경
          color: selected ? BubdongColors.bgFieldSelected : color.tint,
          borderRadius: BubdongRadius.r15All,
          border: Border.all(
            color: selected ? color.accent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.accent.withValues(alpha: 0.3),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.accent, size: 24),
            const SizedBox(height: BubdongSpacing.s4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: BubdongTypography.h5.copyWith(
                color: BubdongColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}