import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_flow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/notice_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/seat_chips.dart';

/// 인터넷 좌석과 사용목적을 적는 신청서 (Figma 프레임 13)
class ComputerApplyPage extends StatefulWidget {
  const ComputerApplyPage({
    super.key,
    required this.remaining,
    required this.selected,
  });

  final List<Facility> remaining; // 이 신청서 다음에 쓸 신청서들
  final List<Facility> selected; // 고른 이용대장 전체 (완료 화면 제목에 넘김)

  @override
  State<ComputerApplyPage> createState() => _ComputerApplyPageState();
}

class _ComputerApplyPageState extends State<ComputerApplyPage> {

  static const _seatCount = 10;

  final _purposeController = TextEditingController();
  int? _seat;

  // 좌석을 고르고 사용목적을 적어야 신청 가능
  bool get _isValid =>
      _seat != null && _purposeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _purposeController.addListener(() => setState(() {})); // 입력할 때마다 버튼 상태 갱신
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BubdongPageHeader(
            title: '${Facility.internet.label} 이용 신청서',
            subtitle: '좌석과 사용 정보를 알려주세요',
          ),
          const SizedBox(height: BubdongLayout.applyHeaderToCardGap),
          BubdongContentCard(
            width: BubdongLayout.formCardWidth,
            height: BubdongLayout.applyCardHeight,
            padding: BubdongLayout.applyCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '좌석번호',
                      style: BubdongTypography.sectionTitle.copyWith(
                        color: BubdongColors.textSectionTitle,
                      ),
                    ),
                    Text(
                      '최대 40분',
                      style: BubdongTypography.guide.copyWith(
                        color: BubdongColors.textGuide,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BubdongSpacing.s28),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BubdongLayout.seatGridInset,
                  ),
                  child: SeatChips(
                    seatCount: _seatCount,
                    selected: _seat,
                    onSelect: (seat) => setState(() => _seat = seat),
                  ),
                ),
                const SizedBox(height: BubdongLayout.seatGridToInputGap),
                BubdongInput(
                  label: '사용목적',
                  hintText: '자료 검색',
                  controller: _purposeController,
                ),
                const SizedBox(height: BubdongLayout.seatInputToNoticeGap),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: BubdongLayout.seatGridInset,
                  ),
                  child: NoticeBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: BubdongLayout.applyCardToButtonGap),
          BubdongActionRow(
            nextLabel: '컴퓨터 신청하기', // Figma 문구
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _isValid
                ? () => openNextApplication(
                      context,
                      widget.remaining,
                      selected: widget.selected,
                    )
                : null, // 좌석과 사용목적을 채워야 누를 수 있음
          ),
        ],
      ),
    );
  }
}
