import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 약관 전체 동의 상자
class AgreeAllBox extends StatelessWidget {
  const AgreeAllBox({super.key, required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BubdongSpacing.s24),
      decoration: BoxDecoration(
        color: BubdongColors.bgFieldSelected,
        borderRadius: BubdongRadius.r15All,
        boxShadow: [BubdongShadow.inputDefault],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: checked ? BubdongColors.brandPrimary : BubdongColors.bgSurface,
                    borderRadius: BubdongRadius.r4All,
                    border: Border.all(
                      color: checked ? BubdongColors.brandPrimary : BubdongColors.borderCard,
                      width: 2,
                    ),
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 16, color: BubdongColors.bgSurface)
                      : null,
                ),
                const SizedBox(width: BubdongSpacing.s20),
                Text(
                  '모두 동의합니다',
                  style: BubdongTypography.subtitle.copyWith(color: BubdongColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s16),
          Text(
            '민간정보 수집이용, 개인정보의 수집 및 이용, 온라인신청 서비스 정책, 고유식별정보 수집 및 이용 항목에 대해 모두 동의합니다.\n'
                '각 사항에 대한 동의 여부를 개별적으로 선택하실 수 있으며, 선택 동의 사항에 대한 동의를 거부하여도 서비스를 이용하실 수 있습니다.',
            style: BubdongTypography.bodySm.copyWith(color: BubdongColors.textPlaceholder),
          ),
        ],
      ),
    );
  }
}