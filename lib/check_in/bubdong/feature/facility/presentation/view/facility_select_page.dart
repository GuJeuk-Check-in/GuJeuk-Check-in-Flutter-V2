import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/visitor_type.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_flow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/auto_save_toast.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/facility_card_color.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_entry.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/used_time_text.dart';

/// 오늘 사용할 이용대장 고르기 (여러 개 선택 가능)
class FacilitySelectPage extends StatefulWidget {
  const FacilitySelectPage({
    super.key,
    this.visitorType = VisitorType.child,
    this.guest,
  });

  final VisitorType visitorType; // 아이·어른에 따라 이용대장 개수와 신청서 여부가 다름
  final GuestbookEntry? guest; // 방명록에서 누른 사람 (없으면 새로 고르는 흐름)

  @override
  State<FacilitySelectPage> createState() => _FacilitySelectPageState();
}

class _FacilitySelectPageState extends State<FacilitySelectPage>
    with SingleTickerProviderStateMixin {
  static const _autoSaveDelay = Duration(seconds: 3); // Figma "3초"

  // 방명록에서 들어왔을 때 고른 뒤 3초가 지나면 자동 저장
  late final AnimationController _autoSave;
  AutoSaveStatus? _autoSaveStatus; // null이면 토스트 없음

  @override
  void initState() {
    super.initState();
    // dispose에서 처음 만들어지지 않게 화면이 생길 때 바로 만듦
    _autoSave = AnimationController(vsync: this, duration: _autoSaveDelay)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _save();
      });
  }

  @override
  void dispose() {
    _autoSave.dispose();
    super.dispose();
  }

  // 고를 때마다 3초를 처음부터 다시 셈
  void _restartAutoSave() {
    if (widget.guest == null) return;
    if (_selected.isEmpty) {
      _autoSave.stop();
      _autoSaveStatus = null; // 다 지우면 저장할 것이 없으니 토스트 숨김
      return;
    }
    _autoSaveStatus = AutoSaveStatus.counting;
    _autoSave.forward(from: 0);
  }

  void _save() {
    // TODO: API 연결 시 고른 이용대장 저장
    setState(() => _autoSaveStatus = AutoSaveStatus.saved);
  }

  int get _secondsLeft =>
      (_autoSaveDelay.inSeconds * (1 - _autoSave.value)).ceil();

  static const _columnCount = 4;

  // TODO: API 연결 시 교체 (자리 없는 이용대장과 남은 시간)
  static const Map<Facility, int> _unavailable = {};

  final _selected = <Facility>{}; // 고른 순서대로 들어감

  List<Facility> get _facilities => widget.visitorType.facilities;

  // 써야 할 신청서 목록 (어른은 신청서 없이 바로 완료)
  List<Facility> get _applicationQueue => widget.visitorType.writesApplication
      ? _selected.where((f) => f.needsApplication).toList()
      : const [];

  void _toggle(Facility facility) {
    setState(() {
      if (!_selected.remove(facility)) _selected.add(facility);
      _restartAutoSave();
    });
  }

  // 방명록에서 들어왔을 때 이미 고른 이용대장 상태 (이용 완료·이용 중)
  BubdongCardStatus? _guestStatusOf(Facility facility) {
    final guest = widget.guest;
    if (guest == null || !guest.facilities.contains(facility)) return null;
    return guest.completedFacilities.contains(facility)
        ? BubdongCardStatus.completed
        : BubdongCardStatus.inUse;
  }

  BubdongCardStatus _statusOf(Facility facility) {
    final guestStatus = _guestStatusOf(facility);
    if (guestStatus != null) return guestStatus;
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

    final autoSaveStatus = _autoSaveStatus;

    return BubdongBaseScaffold(
      showHomeButton: true,
      // TODO: "저장됨"이 몇 초 뒤 사라지는지 정해지면 반영 (지금은 다시 고를 때까지 보임)
      topRight: autoSaveStatus == null
          ? null
          : AutoSaveToast(
              status: autoSaveStatus,
              secondsLeft: _secondsLeft,
              progress: 1 - _autoSave.value,
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BubdongPageHeader(
            title: '오늘 어떤 이용대장을 사용하시나요?',
            // 방명록에서 아이를 눌렀을 때만 부제 (어른·새로 고르는 흐름은 없음)
            subtitle: widget.guest?.visitorType == VisitorType.child
                ? '${widget.guest!.name} 님, 이용할 이용대장을 모두 선택해주세요'
                : null,
          ),
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
          // 고르면 선택 요약, 고르기 전에는 방명록이면 이용한 시간 (자리는 유지)
          Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: _selected.isNotEmpty,
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
              if (widget.guest != null)
                Visibility(
                  visible: _selected.isEmpty,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: _UsedTimeRow(usedTime: widget.guest!.usedTime),
                ),
            ],
          ),
          const SizedBox(height: BubdongLayout.facilitySummaryToButtonGap),
          BubdongActionRow(
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _selected.isEmpty
                ? null // 하나도 안 고르면 다음 비활성
                : () => openNextApplication(
                      context,
                      _applicationQueue,
                      selected: _selected.toList(),
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
              // TODO: 어른은 신청서 없이 바로 완료라 표시를 뺄지 디자이너 확인
              subtitle: facility.needsApplication ? '신청서 작성' : null,
              color: facility.cardColor,
              status: _statusOf(facility),
              remainingMinutes: _unavailable[facility],
              // TODO: 이용 중·이용 완료 카드를 눌렀을 때 동작 디자이너 확인 (지금은 안 눌림)
              onTap: _guestStatusOf(facility) == null
                  ? () => _toggle(facility)
                  : () {},
            ),
          ),
        for (var i = row.length; i < _columnCount; i++)
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

/// "이용한 시간 : 1시간 20분" 줄 (Figma 방명록 흐름 이용대장 선택 화면)
class _UsedTimeRow extends StatelessWidget {
  const _UsedTimeRow({required this.usedTime});

  final Duration usedTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic, // 크기가 다른 두 글자의 바닥선 맞춤
      spacing: BubdongSpacing.s8, // Figma 두 글자 사이
      children: [
        Text(
          '이용한 시간 :',
          style: BubdongTypography.h4.copyWith(color: BubdongColors.textCaption),
        ),
        Text(
          usedTime.usedTimeText,
          style: BubdongTypography.h2.copyWith(color: BubdongColors.textAccentDark),
        ),
      ],
    );
  }
}
