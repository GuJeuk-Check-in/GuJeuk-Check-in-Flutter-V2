import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 인터넷 좌석 고르기 (한 줄 5개, 하나만 선택)
class SeatChips extends StatelessWidget {
  const SeatChips({
    super.key,
    required this.seatCount,
    required this.selected,
    required this.onSelect,
  });

  static const _columnCount = 5;

  final int seatCount;
  final int? selected; // 고른 좌석 번호 (없으면 null)
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final seats = [for (var i = 1; i <= seatCount; i++) i];
    final rows = [
      for (var i = 0; i < seats.length; i += _columnCount)
        seats.skip(i).take(_columnCount).toList(),
    ];

    return Column(
      spacing: BubdongSpacing.s16, // Figma 줄 사이
      children: [for (final row in rows) _buildRow(row)],
    );
  }

  // 좌석 한 줄 (마지막 줄이 5개보다 적으면 빈칸으로 너비 맞춤)
  Widget _buildRow(List<int> row) {
    return Row(
      spacing: BubdongSpacing.s20, // Figma 버튼 사이
      children: [
        for (final seat in row)
          Expanded(
            child: BubdongButton(
              label: '$seat번',
              variant: seat == selected
                  ? BubdongButtonVariant.seatSelected
                  : BubdongButtonVariant.seat,
              onPressed: () => onSelect(seat),
            ),
          ),
        for (var i = row.length; i < _columnCount; i++)
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
