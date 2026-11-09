import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 화면 아래 이전 / 다음 버튼 줄 (회원가입·이용대장 선택에서 같이 씀)
class BubdongActionRow extends StatelessWidget {
  const BubdongActionRow({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.nextLabel = '다음',
  });

  final VoidCallback onPrevious;
  final VoidCallback? onNext; // null이면 비활성
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: BubdongLayout.actionRowWidth,
      ),
      child: Row(
        children: [
          Expanded(
            child: BubdongButton(
              label: '이전',
              variant: BubdongButtonVariant.toneMedium,
              onPressed: onPrevious,
            ),
          ),
          const SizedBox(width: BubdongSpacing.s40),
          Expanded(
            child: BubdongButton(label: nextLabel, onPressed: onNext),
          ),
        ],
      ),
    );
  }
}
