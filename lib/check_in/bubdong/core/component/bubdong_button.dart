import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

enum BubdongButtonVariant { main, tone }
enum BubdongButtonSize { large, small }
enum _ButtonState { normal, pressed, disabled, loading }

class BubdongButton extends StatefulWidget {
  const BubdongButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = BubdongButtonVariant.main,
    this.size = BubdongButtonSize.large,
    this.width,
  });

  final String label;
  final double? width;
  final VoidCallback? onPressed; // null이면 비활성
  final Widget? icon;
  final bool isLoading;
  final BubdongButtonVariant variant;
  final BubdongButtonSize size;

  @override
  State<BubdongButton> createState() => _BubdongButtonState();
}

class _BubdongButtonState extends State<BubdongButton> {
  bool _isPressed = false;

  // 비활성이거나 로딩 중이면 못 누름 (로딩 중 중복 클릭 방지)
  bool get _canPress => widget.onPressed != null && !widget.isLoading;

  // 우선순위: 로딩 → 비활성 → 눌림 → 기본
  _ButtonState get _state {
    if (widget.isLoading) return _ButtonState.loading;
    if (widget.onPressed == null) return _ButtonState.disabled;
    if (_isPressed) return _ButtonState.pressed;
    return _ButtonState.normal;
  }

  _ButtonColors get _colors {
    switch (widget.variant) {
      case BubdongButtonVariant.main:
        switch (_state) {
          case _ButtonState.normal:
            return const _ButtonColors(
              background: BubdongColors.actionPrimary,
              border: Colors.transparent,
              text: BubdongColors.textPrimary,
            );
          case _ButtonState.pressed:
          case _ButtonState.loading:
            return const _ButtonColors(
              background: BubdongColors.actionPrimaryPressed,
              border: Colors.transparent,
              text: BubdongColors.textPrimary,
            );
          case _ButtonState.disabled:
            return const _ButtonColors(
              background: BubdongColors.bgDisabled,
              border: Colors.transparent,
              text: BubdongColors.textDisabled,
            );
        }

      case BubdongButtonVariant.tone:
        switch (_state) {
          case _ButtonState.normal:
          case _ButtonState.loading:
            return const _ButtonColors(
              background: Colors.transparent,
              border: BubdongColors.brandPrimary,
              text: BubdongColors.textAccentDark,
            );
          case _ButtonState.pressed:
            return const _ButtonColors(
              background: BubdongColors.bgPage,
              border: BubdongColors.brandPrimary,
              text: BubdongColors.textAccentDark,
            );
          case _ButtonState.disabled:
            return const _ButtonColors(
              background: Colors.transparent,
              border: BubdongColors.bgDisabled,
              text: BubdongColors.textDisabled,
            );
        }
    }
  }

  // 크기별 여백 (Figma 확인 후 조정)
  EdgeInsets get _padding {
    switch (widget.size) {
      case BubdongButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: BubdongSpacing.s32,
          vertical: BubdongSpacing.s12,
        );
      case BubdongButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: BubdongSpacing.s16,
          vertical: BubdongSpacing.s4,
        );
    }
  }

  // 크기별 글자 스타일
  TextStyle get _textStyle {
    switch (widget.size) {
      case BubdongButtonSize.large:
        return BubdongTypography.button;
      case BubdongButtonSize.small:
        return BubdongTypography.label;
    }
  }

  // 값이 바뀔 때만 다시 그림
  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return GestureDetector(
      // 누르는 순간: 눌림 색으로
      onTapDown: _canPress ? (_) => _setPressed(true) : null,
      // 손을 떼면: 원래 색으로 + 동작 실행
      onTapUp: _canPress
          ? (_) {
        _setPressed(false);
        widget.onPressed!();
      }
          : null,
      // 누른 채로 밖으로 끌어내면: 원래 색으로 (동작은 실행 안 함)
      onTapCancel: _canPress ? () => _setPressed(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // 색이 부드럽게 바뀌도록
        padding: _padding,
        decoration: BoxDecoration(
          color: colors.background,
          // 테두리 없는 상태도 투명 테두리로 두께를 유지 → 상태가 바뀌어도 크기 그대로
          border: Border.all(width: 2, color: colors.border),
          borderRadius: BubdongRadius.r9999All,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: BubdongSpacing.s8),
            ],
            Text(
              widget.label,
              style: _textStyle.copyWith(color: colors.text),
            ),
            if (widget.isLoading) ...[
              const SizedBox(width: BubdongSpacing.s8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.text,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}