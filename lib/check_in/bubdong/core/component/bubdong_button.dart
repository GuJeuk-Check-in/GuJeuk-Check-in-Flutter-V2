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
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final BubdongButtonVariant variant;
  final BubdongButtonSize size;

  @override
  State<BubdongButton> createState() => _BubdongButtonState();
}

class _BubdongButtonState extends State<BubdongButton> {
  bool _isPressed = false;

  _ButtonState get _state {
    if (widget.isLoading) {
      return _ButtonState.loading;
    } else if (widget.onPressed == null) {
      return _ButtonState.disabled;
    } else if (_isPressed) {
      return _ButtonState.pressed;
    }
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
          case _ButtonState.loading:
            return const _ButtonColors(
              background: Colors.transparent,
              border: BubdongColors.brandPrimary,
              text: BubdongColors.textAccentDark,
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: colors.border),
        borderRadius: BubdongRadius.r9999All,
        color: colors.background,
      ),
      padding: EdgeInsets.all(BubdongSpacing.s8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style:BubdongTypography.button.copyWith(color: colors.text),
          ),

        ],
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