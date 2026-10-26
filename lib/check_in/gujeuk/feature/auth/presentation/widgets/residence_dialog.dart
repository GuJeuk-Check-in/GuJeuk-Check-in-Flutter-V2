import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// 거주지 선택 모달. 화면에 띄울 때는 [ResidenceDialog.show]를 사용합니다.
/// 위쪽 검색창에 입력한 글자로 아래 목록을 걸러 보여줍니다.
class ResidenceDialog extends StatefulWidget {
  final List<String> residences;
  final String? selected;
  final ValueChanged<String>? onSelected;
  final VoidCallback? onClose;

  const ResidenceDialog({
    super.key,
    required this.residences,
    this.selected,
    this.onSelected,
    this.onClose,
  });

  /// 고른 동네 이름을 반환합니다. 닫기 버튼이나 바깥 영역을 눌러 닫으면 null을 반환합니다.
  static Future<String?> show(
    BuildContext context, {
    required List<String> residences,
    String? selected,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: ResidenceDialog(
            residences: residences,
            selected: selected,
            onSelected: (residence) => Navigator.of(context).pop(residence),
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  State<ResidenceDialog> createState() => _ResidenceDialogState();
}

class _ResidenceDialogState extends State<ResidenceDialog> {
  String _query = '';

  List<String> get _filtered {
    final query = _query.trim();
    if (query.isEmpty) return widget.residences;
    return widget.residences.where((r) => r.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final residences = _filtered;

    return Container(
      width: 528,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: GujeukColors.bgSurface,
        borderRadius: GujeukRadius.lgAll,
        boxShadow: GujeukShadows.modal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            onChanged: (value) => setState(() => _query = value),
            onClose: widget.onClose,
          ),
          // 목록이 길면 모달이 화면 밖으로 넘치지 않게 스크롤합니다.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
            child: residences.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(GujeukSpacing.s32),
                    child: Text(
                      '검색 결과가 없어',
                      style: GujeukTypography.bodyMdMedium.copyWith(
                        color: GujeukColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: residences.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: GujeukColors.borderCard,
                    ),
                    itemBuilder: (context, index) {
                      final residence = residences[index];
                      return GujeukListItem(
                        label: residence,
                        selected: residence == widget.selected,
                        onTap: () => widget.onSelected?.call(residence),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 연한 파란 배경 위 제목·닫기 버튼·검색창 영역.
class _Header extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClose;

  const _Header({required this.onChanged, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GujeukColors.bgSelectedIndigo,
      padding: const EdgeInsets.fromLTRB(
        GujeukSpacing.s28,
        GujeukSpacing.s24,
        GujeukSpacing.s28,
        GujeukSpacing.s28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const GujeukIcon(GujeukIcons.home),
              const SizedBox(width: GujeukSpacing.s8),
              Expanded(
                child: Text(
                  '어디 살아?',
                  style: GujeukTypography.bodyLg.copyWith(
                    color: GujeukColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: GujeukColors.bgSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: GujeukColors.iconBrand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GujeukSpacing.s20),
          Container(
            height: 56,
            padding: const EdgeInsets.only(
              left: GujeukSpacing.s24,
              right: GujeukSpacing.s20,
            ),
            decoration: BoxDecoration(
              color: GujeukColors.bgSurface,
              borderRadius: GujeukRadius.fullAll,
              border: Border.all(color: GujeukColors.borderFocus, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    cursorColor: GujeukColors.actionPrimary,
                    style: GujeukTypography.bodyMdMedium.copyWith(
                      color: GujeukColors.textPrimary,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: '눌러서 거주지를 검색해줘',
                      hintStyle: GujeukTypography.bodyMdMedium.copyWith(
                        color: GujeukColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: GujeukSpacing.s12),
                const GujeukIcon(GujeukIcons.search),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
