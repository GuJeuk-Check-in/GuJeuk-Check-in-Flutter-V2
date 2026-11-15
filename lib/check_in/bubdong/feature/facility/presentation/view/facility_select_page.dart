import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_error.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/data/remote_user_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/sign_up_request.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/data/remote_purpose_repository.dart';
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
    this.userId,
    this.signUpRequest,
  });

  final VisitorType visitorType; // 아이·어른에 따라 이용대장 개수와 신청서 여부가 다름
  final GuestbookEntry? guest; // 방명록에서 누른 사람 (없으면 새로 고르는 흐름)
  // TODO(bubdong): 방명록 작성 API(POST /check-in) 연동 보류. 사용자 값을 어떻게 보내는지 백엔드 확인 중
  //  (응답은 회원가입과 같게 처리: true인 신청서만 띄우기, logId 넘기기, 500 문구 "기록하지 못했어요. 잠시 후 다시 시도해주세요")
  //  어른 흐름도 답 받을 때까지 서버 요청 없이 완료 화면으로
  final int? userId; // 다시 온 친구 (1단계 전화번호 조회 결과)
  final SignUpRequest? signUpRequest; // 처음 온 친구 (고른 뒤 회원가입 요청)

  @override
  State<FacilitySelectPage> createState() => _FacilitySelectPageState();
}

class _FacilitySelectPageState extends State<FacilitySelectPage>
    with SingleTickerProviderStateMixin {
  static const _autoSaveDelay = Duration(seconds: 3); // Figma "3초"

  // 방명록에서 들어왔을 때 고른 뒤 3초가 지나면 자동 저장
  late final AnimationController _autoSave;
  AutoSaveStatus? _autoSaveStatus; // null이면 토스트 없음

  final _purposeRepository = RemotePurposeRepository(bubdongApiClient);

  Map<Facility, int> _purposeIds = {}; // 서버에 있는 이용대장과 그 id
  bool _isLoading = true; // 이용대장 불러오는 중
  String? _error; // 실패했을 때 보여줄 문구

  final _userRepository = RemoteUserRepository(bubdongApiClient);
  bool _isSubmitting = false; // 회원가입 요청 중
  String? _submitError; // 회원가입 실패 문구

  /// 다음: 처음 온 친구면 가입 요청 후, 아니면 바로 신청서로
  void _next() {
    final request = widget.signUpRequest;
    if (request == null) {
      openNextApplication(
        context,
        _applicationQueue,
        selected: _selected.toList(),
      );
      return;
    }
    _signUp(request);
  }

  /// 회원가입 + 첫 방문 기록. 서버가 알려준 신청서만 이어서 씀
  Future<void> _signUp(SignUpRequest request) async {
    final selected = _selected.toList();
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      final result = await _userRepository.signUp(request, [
        for (final facility in selected) _purposeIds[facility]!,
      ]);
      if (!mounted) return;
      final queue = selected.where((facility) => switch (facility) {
            Facility.internet => result.pcForm,
            Facility.karaoke => result.singForm,
            Facility.tableTennis => result.pingForm,
            _ => false,
          }).toList();
      openNextApplication(
        context,
        queue,
        selected: selected,
        logId: result.logId,
      );
    } catch (error) {
      if (!mounted) return;
      // 400·409는 서버 문구(예: 이미 등록된 전화번호입니다.), 나머지는 공통 문구
      setState(() => _submitError = serverErrorMessage(error) ??
          '가입하지 못했어요. 잠시 후 다시 시도해주세요');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 서버에서 이용대장 목록을 받아 앱 이용대장과 짝지음
  Future<void> _loadPurposes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final purposes = await _purposeRepository.fetchAll();
      if (!mounted) return; // 기다리는 동안 화면을 나갔으면 멈춤
      setState(() {
        _purposeIds = {
          for (final purpose in purposes)
            ?Facility.byName(purpose.name): purpose.id, // 앱에 없는 이름은 뺌
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '이용대장을 불러오지 못했어요. 잠시 후 다시 시도해주세요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPurposes();
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
    // TODO(bubdong): 7번 본인 이용대장 수정 API(PATCH /check-in/purpose)로 저장한 뒤 "저장됨" 표시
    setState(() => _autoSaveStatus = AutoSaveStatus.saved);
  }

  int get _secondsLeft =>
      (_autoSaveDelay.inSeconds * (1 - _autoSave.value)).ceil();

  static const _columnCount = 4;

  // TODO: API 연결 시 교체 (자리 없는 이용대장과 남은 시간)
  static const Map<Facility, int> _unavailable = {};

  final _selected = <Facility>{}; // 고른 순서대로 들어감

  // 아이·어른 목록 중 서버에 있는 이용대장만 (순서는 Figma 순서 유지)
  List<Facility> get _facilities =>
      widget.visitorType.facilities.where(_purposeIds.containsKey).toList();

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
    if (_unavailable.containsKey(facility)) {
      return BubdongCardStatus.unavailable;
    }
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
          _buildGrid(rows),
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
          if (_submitError != null) ...[
            Text(
              _submitError!,
              style: BubdongTypography.bodySm.copyWith(
                color: BubdongColors.borderError,
              ),
            ),
            const SizedBox(height: BubdongSpacing.s12),
          ],
          BubdongActionRow(
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _selected.isEmpty
                ? null // 하나도 안 고르면 다음 비활성
                : _next,
            isNextLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  /// 카드 자리: 불러오는 중 / 실패 / 고를 것 없음 / 카드 목록
  Widget _buildGrid(List<List<Facility>> rows) {
    if (_isLoading) {
      return const CircularProgressIndicator(color: BubdongColors.brandPrimary);
    }
    final message = _error ?? (rows.isEmpty ? '지금 고를 수 있는 이용대장이 없어요' : null);
    if (message != null) {
      return Text(
        message,
        style: BubdongTypography.bodySm.copyWith(
          color: BubdongColors.textSecondary,
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: BubdongLayout.facilityGridWidth,
      ),
      child: Column(
        spacing: BubdongLayout.facilityGridRowGap,
        children: [for (final row in rows) _buildRow(row)],
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
          style: BubdongTypography.h4.copyWith(
            color: BubdongColors.textCaption,
          ),
        ),
        Text(
          usedTime.usedTimeText,
          style: BubdongTypography.h2.copyWith(
            color: BubdongColors.textAccentDark,
          ),
        ),
      ],
    );
  }
}
