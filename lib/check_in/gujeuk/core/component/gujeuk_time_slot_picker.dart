import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_field_label.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_time_slot.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// Figma `Time Slot` 섹션 · 라벨과 범례, 6열 [GujeukTimeSlot] 그리드, 안내문.
/// [reservedTimes]·[pastTimes]에 든 시간은 회색으로 막고, 나머지를 누르면 [onSelected]로 알려줍니다.
/// [onSelected]가 null이면 모든 칸을 회색으로 막습니다.
class GujeukTimeSlotPicker extends StatelessWidget {
  final List<String> times;
  final Set<String> reservedTimes;
  final Set<String> pastTimes;
  final String? selectedTime;
  final ValueChanged<String>? onSelected;

  /// 예약 현황을 불러오는 중. 칸을 흐리게 그리고 누를 수 없게 막습니다.
  final bool isLoading;

  const GujeukTimeSlotPicker({
    super.key,
    required this.times,
    this.reservedTimes = const {},
    this.pastTimes = const {},
    this.selectedTime,
    this.onSelected,
    this.isLoading = false,
  });

  static const _columns = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const GujeukFieldLabel(
              label: '몇 시에 이용할 거야?',
              icon: GujeukIcons.clock,
            ),
            if (isLoading) ...[
              const SizedBox(width: GujeukSpacing.s16),
              const _LoadingHint(),
            ],
            const Spacer(),
            const _Legend(),
          ],
        ),
        const SizedBox(height: GujeukSpacing.s20),
        AnimatedOpacity(
          opacity: isLoading ? 0.4 : 1,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: isLoading,
            child: Column(
              children: [
                for (
                  var start = 0;
                  start < times.length;
                  start += _columns
                ) ...[
                  if (start > 0) const SizedBox(height: GujeukSpacing.s24),
                  _row(start),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: GujeukSpacing.s20),
        Text(
          '1시간 단위로 예약할 수 있어 · 회색 시간은 이미 지났거나 다른 친구가 예약했어',
          style: GujeukTypography.bodySm.copyWith(
            color: GujeukColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// 마지막 줄이 6개보다 적어도 슬롯 너비가 다른 줄과 같도록 빈칸을 채웁니다.
  Widget _row(int start) {
    return Row(
      children: [
        for (var column = 0; column < _columns; column++) ...[
          if (column > 0) const SizedBox(width: GujeukSpacing.s16),
          Expanded(
            child: start + column < times.length
                ? _slot(times[start + column])
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  Widget _slot(String time) {
    return GujeukTimeSlot(
      time: time,
      selected: time == selectedTime,
      reserved: reservedTimes.contains(time),
      passed: pastTimes.contains(time),
      onTap: onSelected == null ? null : () => onSelected!(time),
    );
  }
}

/// 예약 현황을 불러오는 동안 라벨 옆에 띄웁니다.
class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: GujeukSpacing.s8),
        Text(
          '예약 현황을 확인하는 중이야',
          style: GujeukTypography.bodySm.copyWith(
            color: GujeukColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _item(
          '선택 가능',
          GujeukColors.bgField,
          Border.all(color: GujeukColors.borderSubtle),
        ),
        const SizedBox(width: GujeukSpacing.s20),
        _item('선택함', GujeukColors.actionPrimary),
        const SizedBox(width: GujeukSpacing.s20),
        _item('예약 마감', GujeukColors.bgDisabled),
      ],
    );
  }

  Widget _item(String label, Color color, [BoxBorder? border]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border,
          ),
        ),
        const SizedBox(width: GujeukSpacing.s8),
        Text(
          label,
          style: GujeukTypography.bodySm.copyWith(
            color: GujeukColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
