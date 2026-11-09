import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_flow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/facility_card_color.dart';

/// 오늘 사용할 이용대장 고르기 (여러 개 선택 가능)
class FacilitySelectPage extends StatefulWidget {
  const FacilitySelectPage({super.key, this.guestName});

  final String? guestName; // 방명록에서 누른 사람 (화면에는 안 보이고 넘기기만)

  @override
  State<FacilitySelectPage> createState() => _FacilitySelectPageState();
}

class _FacilitySelectPageState extends State<FacilitySelectPage> {
  static const _columnCount = 4;

  // 아이들 흐름·방명록 흐름에서 보여줄 이용대장 (아이들 기준 8개)
  static final _facilities = Facility.children;

  // TODO: API 연결 시 교체 (자리 없는 이용대장과 남은 시간)
  static const Map<Facility, int> _unavailable = {};

  final _selected = <Facility>{}; // 고른 순서대로 들어감

  void _toggle(Facility facility) {
    setState(() {
      if (!_selected.remove(facility)) _selected.add(facility);
    });
  }

  BubdongCardStatus _statusOf(Facility facility) {
    if (_unavailable.containsKey(facility)) return BubdongCardStatus.unavailable;
    return _selected.contains(facility)
        ? BubdongCardStatus.selected
        : BubdongCardStatus.normal;
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < _facilities.length; i += _columnCount)
        _facilities.skip(i).take(_columnCount).toList(),
    ];

    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BubdongPageHeader(title: '오늘 어떤 이용대장을 사용하시나요?'),
          const SizedBox(height: BubdongSpacing.s40),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: BubdongLayout.facilityGridWidth,
            ),
            child: Column(
              spacing: BubdongLayout.facilityGridRowGap,
              children: [
                for (final row in rows) _buildRow(row),
              ],
            ),
          ),
          const SizedBox(height: BubdongLayout.facilityGridToSummaryGap),
          Visibility(
            visible: _selected.isNotEmpty, // 고르기 전에는 숨기고 자리는 유지
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(
              '선택한 이용대장 ${_selected.length}개 · '
              '${_selected.map((f) => f.label).join(', ')}',
              style: BubdongTypography.selectionSummary.copyWith(
                color: BubdongColors.textAccentDark, // Figma #9B4D00
              ),
            ),
          ),
          const SizedBox(height: BubdongLayout.facilitySummaryToButtonGap),
          BubdongActionRow(
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _selected.isEmpty
                ? null // 하나도 안 고르면 다음 비활성
                : () => openNextApplication(
                      context,
                      _selected.where((f) => f.needsApplication).toList(),
                    ),
          ),
        ],
      ),
    );
  }

  // 카드 한 줄 (마지막 줄이 4장보다 적으면 빈칸으로 너비 맞춤)
  Widget _buildRow(List<Facility> row) {
    return Row(
      spacing: BubdongSpacing.s40,
      children: [
        for (final facility in row)
          Expanded(
            child: BubdongFacilityCard(
              title: facility.label,
              subtitle: facility.needsApplication ? '신청서 작성' : null,
              color: facility.cardColor,
              status: _statusOf(facility),
              remainingMinutes: _unavailable[facility],
              onTap: () => _toggle(facility),
            ),
          ),
        for (var i = row.length; i < _columnCount; i++)
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
