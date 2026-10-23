import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// Figma `Input` (이름·전화번호·거주지 검색).
/// Placeholder → Filled → Focused 상태는 입력값과 포커스로 자동 결정됩니다.
class GujeukInput extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final String? errorText;

  /// 입력할 수 있는 최대 글자 수. 넘기지 않으면 제한이 없습니다.
  final int? maxLength;

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
    this.errorText,
    this.maxLength,
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

    final field = Container(
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
              onTapOutside: (_) => _focusNode.unfocus(),
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              // TextField.maxLength는 글자 수 카운터를 함께 그리므로 formatter로 제한합니다.
              inputFormatters: [
                if (widget.maxLength != null)
                  LengthLimitingTextInputFormatter(widget.maxLength),
              ],
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

    final errorText = widget.errorText;

    // 에러 문구는 입력창 박스 밖, 아래에 그려 박스 크기가 변하지 않게 합니다.
    // 에러 유무와 상관없이 항상 Column을 돌려줘야 TextField가 다시 만들어지지 않아
    // 포커스와 한글 조합이 유지됩니다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        if (errorText != null) ...[
          const SizedBox(height: GujeukSpacing.s16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s28),
            child: Text(
              errorText,
              style: GujeukTypography.bodyMd.copyWith(
                color: GujeukColors.decorRed,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
