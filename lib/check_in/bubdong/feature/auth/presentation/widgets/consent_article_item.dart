import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// 개인정보 동의 조항 하나 (눌러서 펼치기 + 동의 선택)
class ConsentArticleItem extends StatelessWidget {
  const ConsentArticleItem({
    super.key,
    required this.title,
    required this.content,
    required this.expanded,
    required this.agreed,
    required this.onToggle,
    required this.onAgreeChanged,
  });

  final String title;
  final String content;
  final bool expanded;
  final bool? agreed; // true: 동의함, false: 동의안함, null: 안 고름
  final VoidCallback onToggle;
  final ValueChanged<bool> onAgreeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        BubdongSpacing.s32,
        BubdongSpacing.s24,
        BubdongSpacing.s32,
        BubdongSpacing.s20,
      ),
      decoration: BoxDecoration(
        color: expanded ? BubdongColors.brandSubtle : BubdongColors.bgSurface,
        borderRadius: BubdongRadius.r15All,
        border: Border.all(
          color: expanded ? BubdongColors.brandPrimary : BubdongColors.borderCard,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 줄 (누르면 펼치기/접기)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: BubdongTypography.subtitle.copyWith(color: BubdongColors.textPrimary),
                  ),
                ),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: BubdongColors.textPrimary,
                ),
              ],
            ),
          ),

          // 펼쳤을 때만 내용
          if (expanded) ...[
            const SizedBox(height: BubdongSpacing.s20),
            _ArticleContent(content: content),
          ],

          const SizedBox(height: BubdongSpacing.s16),

          // 동의함 / 동의안함
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ConsentRadio(
                  label: '동의함',
                  selected: agreed == true,
                  onTap: () => onAgreeChanged(true),
                ),
                const SizedBox(width: BubdongSpacing.s24),
                _ConsentRadio(
                  label: '동의안함',
                  selected: agreed == false,
                  onTap: () => onAgreeChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 조항 내용 (길면 안에서 스크롤)
class _ArticleContent extends StatefulWidget {
  const _ArticleContent({required this.content});

  final String content;

  @override
  State<_ArticleContent> createState() => _ArticleContentState();
}

class _ArticleContentState extends State<_ArticleContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BubdongLayout.consentContentHeight, // 펼친 조항 내용 높이
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // 스크롤 막대 항상 보이게
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(right: BubdongSpacing.s24),
          child: Text(
            widget.content,
            style: BubdongTypography.bodySm.copyWith(color: BubdongColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// 동그라미 선택 버튼
class _ConsentRadio extends StatelessWidget {
  const _ConsentRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? BubdongColors.brandPrimary : BubdongColors.textPrimary,
                width: 2,
              ),
            ),
            child: selected
                ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: BubdongColors.brandPrimary,
              ),
            )
                : null,
          ),
          const SizedBox(width: BubdongSpacing.s8),
          Text(label, style: BubdongTypography.subtitle.copyWith(color: BubdongColors.textPrimary)),
        ],
      ),
    );
  }
}