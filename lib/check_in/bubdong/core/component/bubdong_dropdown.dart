import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class BubdongDropdown extends StatefulWidget {
  const BubdongDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<BubdongDropdown> createState() => _BubdongDropdownState();
}

class _BubdongDropdownState extends State<BubdongDropdown> {
  bool _isOpen = false; // 지금 열려 있는지
  final _overlayController = OverlayPortalController(); // 패널 띄우기/숨기기
  final _link = LayerLink(); // 박스와 패널을 연결
  final _tapGroup = Object(); // 박스와 패널을 "같은 영역"으로 묶는 이름표

  void _open() {
    setState(() => _isOpen = true);
    _overlayController.show();
  }

  void _close() {
    if (!_isOpen) return; // 이미 닫혀 있으면 아무것도 안 함
    setState(() => _isOpen = false);
    _overlayController.hide();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _select(String item) {
    widget.onChanged(item); // 고른 값을 밖에 알려줌
    _close(); // 고르면 닫기
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null; // 고른 값이 있는지

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 질문 글자
        Text(
          widget.label,
          style: BubdongTypography.subtitle.copyWith(
            color: BubdongColors.textPrimary,
          ),
        ),
        const SizedBox(height: BubdongSpacing.s4),

        // 박스 + 패널
        OverlayPortal(
          controller: _overlayController,
          overlayChildBuilder: (context) => _buildPanel(),
          child: CompositedTransformTarget(
            link: _link,
            child: TapRegion(
              groupId: _tapGroup,
              onTapOutside: (_) => _close(), // 박스·패널 바깥을 누르면 닫기
              child: GestureDetector(
                onTap: widget.enabled ? _toggle : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BubdongSpacing.s20,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? BubdongColors.bgFieldSelected
                        : BubdongColors.bgFieldDisabled,
                    borderRadius: BubdongRadius.r15All,
                    boxShadow: widget.enabled
                        ? [BubdongShadow.inputDefault]
                        : [], // 비활성: 그림자 없음
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.value ?? widget.hintText, // 고른 값이 없으면 안내 글자
                          style: BubdongTypography.placeHolder.copyWith(
                            color: !widget.enabled
                                ? BubdongColors.textFieldDisabled // 비활성
                                : hasValue
                                ? BubdongColors.textPrimary // 고른 값: 검정
                                : BubdongColors.textPlaceholder, // 안내 글자: 회색
                          ),
                        ),
                      ),
                      Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: BubdongColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 열렸을 때 박스 아래에 뜨는 목록 패널
  Widget _buildPanel() {
    return Positioned(
      width: _link.leaderSize?.width, // 패널 너비 = 박스 너비
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.bottomLeft, // 박스 왼쪽 아래에 붙이기
        offset: const Offset(0, 16), // 박스보다 16 아래 (Figma 확인 후 조정)
        child: TapRegion(
          groupId: _tapGroup, // 박스와 같은 영역으로 취급 → 패널 안을 눌러도 안 닫힘
          child: Material(
            color: Colors.transparent, // 노란 밑줄 방지용
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300), // 항목이 많으면 스크롤
              padding: const EdgeInsets.symmetric(
                horizontal: BubdongSpacing.s20,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: BubdongColors.bgFieldSelected,
                borderRadius: BubdongRadius.r15All,
                boxShadow: [BubdongShadow.inputDefault],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 26, // 항목 사이 간격 (Figma 계산값)
                  children: [
                    for (final item in widget.items)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque, // 글자 옆 빈 곳도 눌리게
                        onTap: () => _select(item),
                        child: SizedBox(
                          width: double.infinity, // 한 줄 전체를 누를 수 있게
                          child: Text(
                            item,
                            style: BubdongTypography.placeHolder.copyWith(
                              color: BubdongColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}