import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

/// Figma `Input` (이름·전화번호·거주지 검색).
/// Placeholder → Filled → Focused 상태는 입력값과 포커스로 자동 결정됩니다.
class GujeukInput extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  /// 거주지 검색일 때 오른쪽 아이콘을 켭니다.
  final bool showTrailingIcon;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukInput({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.showTrailingIcon = false,
    this.width = double.infinity,
  });

  @override
  State<GujeukInput> createState() => _GujeukInputState();
}

class _GujeukInputState extends State<GujeukInput> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _focusNode.removeListener(_rebuild);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final filled = _controller.text.isNotEmpty;

    return Container(
      width: widget.width,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s32),
      decoration: BoxDecoration(
        color: GujeukColors.bgField,
        borderRadius: GujeukRadius.fullAll,
        border: focused
            ? Border.all(color: GujeukColors.borderFocus, width: 4)
            : null,
        boxShadow: filled && !focused
            ? GujeukShadows.blue3dStrong
            : GujeukShadows.blue3d10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              cursorColor: GujeukColors.actionPrimary,
              style: GujeukTypography.bodyMdMedium.copyWith(
                color: GujeukColors.textPrimary,
              ),
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
                hintStyle: GujeukTypography.bodyMdMedium.copyWith(
                  color: GujeukColors.textTertiary,
                ),
              ),
            ),
          ),
          if (widget.showTrailingIcon) ...[
            const SizedBox(width: GujeukSpacing.s16),
            const GujeukIcon(GujeukIcons.inputTrailing),
          ],
        ],
      ),
    );
  }
}
