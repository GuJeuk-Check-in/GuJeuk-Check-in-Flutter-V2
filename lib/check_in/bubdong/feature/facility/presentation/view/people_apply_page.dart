import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_flow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/widgets/notice_box.dart';

/// 함께 이용하는 인원을 적는 신청서 (탁구·노래방, Figma 프레임 14·15)
class PeopleApplyPage extends StatefulWidget {
  const PeopleApplyPage({
    super.key,
    required this.facility,
    required this.remaining,
  });

  final Facility facility; // tableTennis 또는 karaoke
  final List<Facility> remaining; // 이 신청서 다음에 쓸 신청서들

  @override
  State<PeopleApplyPage> createState() => _PeopleApplyPageState();
}

class _PeopleApplyPageState extends State<PeopleApplyPage> {
  final _controller = TextEditingController();

  int get _maxPeople => widget.facility.maxPeople!;

  // 1명 ~ 최대 인원 사이를 적어야 신청 가능
  bool get _isValid {
    final count = int.tryParse(_controller.text);
    return count != null && count >= 1 && count <= _maxPeople;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {})); // 입력할 때마다 버튼 상태 갱신
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Figma 문구 (이용대장마다 다름)
  String get _buttonLabel => switch (widget.facility) {
        Facility.tableTennis => '탁구•포켓볼 신청하기',
        _ => '${widget.facility.label} 신청하기',
      };

  String get _guide => switch (widget.facility) {
        Facility.tableTennis => '최대 40분 · 최대 4명 이용할 수 있어요',
        Facility.karaoke =>
          '최대 2명 · 1명 20분 / 2명 30분 · 초등학교 3학년부터 이용할 수 있어요',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BubdongPageHeader(
            title: '${widget.facility.label} 이용 신청서',
            subtitle: '함께 이용하는 인원을 알려주세요',
          ),
          const SizedBox(height: BubdongLayout.applyHeaderToCardGap),
          BubdongContentCard(
            width: BubdongLayout.formCardWidth,
            height: BubdongLayout.applyCardHeight,
            padding: BubdongLayout.applyCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BubdongInput(
                  label: '사용 인원',
                  hintText: '사용 인원을 적어줘',
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // 1명 ~ 최대 인원 숫자만 들어가게 막음 (그 밖의 값은 입력 자체가 안 됨)
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final count = int.tryParse(newValue.text);
                      final ok = count != null && count >= 1 && count <= _maxPeople;
                      return ok ? newValue : oldValue;
                    }),
                  ],
                ),
                const SizedBox(height: BubdongLayout.applyInputToNoticeGap),
                const NoticeBox(),
                const SizedBox(height: BubdongSpacing.s40),
                Text(
                  _guide,
                  style: BubdongTypography.guide.copyWith(
                    color: BubdongColors.textGuide,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BubdongLayout.applyCardToButtonGap),
          BubdongActionRow(
            nextLabel: _buttonLabel,
            onPrevious: () => Navigator.of(context).pop(),
            onNext: _isValid
                ? () => openNextApplication(
                      context,
                      widget.remaining,
                      current: widget.facility,
                    )
                : null, // 인원을 맞게 적어야 누를 수 있음
          ),
        ],
      ),
    );
  }
}
