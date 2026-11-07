import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

/// Figma `Button`의 Type × Size 조합.
enum BubdongButtonVariant {
  /// Button highlight / 96 · 기본 정보 화면 다음으로 넘어가기
  primaryLarge,

  /// Button highlight / 80 · 회원가입 다음, 동의
  primaryMedium,

  /// Button tone / 80 · 회원가입 이전, 홈 이용 대장 조회
  toneMedium,

  /// Button 노랑 채움 / 80 · 홈 아이들 방문 기록
  yellowMedium,

  /// Button 파랑 채움 / 80 · 홈 어른 방문 기록
  blueMedium,

  /// Buttons/Button-outline / 66 · 학교 검색
  outlineSmall,
}

enum _ButtonState { normal, pressed, disabled, loading }

class BubdongButton extends StatefulWidget {
  const BubdongButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BubdongButtonVariant.primaryMedium,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed; // null이면 비활성
  final BubdongButtonVariant variant;
  final Widget? icon;

  /// 넘기지 않으면 variant의 기본 너비를 씁니다. (대부분 부모를 채움)
  final double? width;

  /// 넘기지 않으면 variant의 기본 높이를 씁니다.
  final double? height;

  /// 넘기지 않으면 variant의 기본 좌우 여백을 씁니다.
  final EdgeInsetsGeometry? padding;

  /// 요청 중이면 글자 옆에 스피너를 띄우고 눌러도 무시합니다.
  final bool isLoading;

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

  // 값이 바뀔 때만 다시 그림
  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final spec = _ButtonSpec.of(widget.variant);
    final colors = spec.colorsOf(_state);

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
        width: widget.width ?? spec.width,
        height: widget.height ?? spec.height,
        alignment: Alignment.center,
        padding:
            widget.padding ?? EdgeInsets.symmetric(horizontal: spec.paddingX),
        decoration: BoxDecoration(
          color: colors.background,
          // 테두리 없는 상태도 투명 테두리로 두께를 유지 → 상태가 바뀌어도 크기 그대로
          border: Border.all(width: spec.borderWidth, color: colors.border),
          borderRadius: spec.radius,
          boxShadow: colors.shadows,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              SizedBox(width: spec.iconGap),
            ],
            Text(
              widget.label,
              style: spec.textStyle.copyWith(color: colors.text),
            ),
            if (widget.isLoading) ...[
              const SizedBox(width: BubdongSpacing.s16),
              SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
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
    this.shadows,
  });

  final Color background;
  final Color border;
  final Color text;
  final List<BoxShadow>? shadows;
}

class _ButtonSpec {
  const _ButtonSpec({
    required this.height,
    this.width = double.infinity,
    required this.paddingX,
    this.iconGap = BubdongSpacing.s16,
    required this.borderWidth,
    required this.radius,
    required this.textStyle,
    required this.normal,
    this.pressed,
    this.loading,
    required this.disabled,
  });

  final double height;
  final double width;
  final double paddingX;
  final double iconGap;
  final double borderWidth;
  final BorderRadius radius;
  final TextStyle textStyle;
  final _ButtonColors normal;
  final _ButtonColors? pressed; // Figma에 눌림 상태가 없으면 null
  final _ButtonColors? loading; // Figma에 로딩 상태가 없으면 null
  final _ButtonColors disabled;

  _ButtonColors colorsOf(_ButtonState state) {
    switch (state) {
      case _ButtonState.normal:
        return normal;
      case _ButtonState.pressed:
        return pressed ?? normal;
      case _ButtonState.loading:
        return loading ?? normal;
      case _ButtonState.disabled:
        return disabled;
    }
  }

  // Button disable: 채워진 버튼 공통
  static const _filledDisabled = _ButtonColors(
    background: BubdongColors.actionDisabled,
    border: Colors.transparent,
    text: BubdongColors.textDisabled,
  );

  // ToneState Disabled: 테두리 버튼 공통
  static const _outlinedDisabled = _ButtonColors(
    background: Colors.transparent,
    border: BubdongColors.actionDisabled,
    text: BubdongColors.textDisabled,
  );

  // MainState Progress
  static const _primaryLoading = _ButtonColors(
    background: BubdongColors.actionPrimaryPressed,
    border: Colors.transparent,
    text: BubdongColors.textOnAction,
  );

  // MainState Press
  static final _primaryPressed = _ButtonColors(
    background: BubdongColors.actionPrimaryPressed,
    border: Colors.transparent,
    text: BubdongColors.textOnAction,
    shadows: [BubdongShadow.buttonGlow],
  );

  static _ButtonSpec of(BubdongButtonVariant variant) {
    switch (variant) {
      case BubdongButtonVariant.primaryLarge:
        return _ButtonSpec(
          height: 96,
          paddingX: BubdongSpacing.s44,
          borderWidth: 4,
          radius: BubdongRadius.r40All,
          textStyle: BubdongTypography.buttonBold,
          normal: _ButtonColors(
            background: BubdongColors.actionPrimary,
            border: Colors.transparent,
            text: BubdongColors.textOnAction,
            shadows: [BubdongShadow.buttonPrimary],
          ),
          pressed: _primaryPressed,
          loading: _primaryLoading,
          disabled: _filledDisabled,
        );
      case BubdongButtonVariant.primaryMedium:
        return _ButtonSpec(
          height: 80,
          paddingX: BubdongSpacing.s44,
          borderWidth: 4,
          radius: BubdongRadius.r40All,
          textStyle: BubdongTypography.buttonBold,
          normal: const _ButtonColors(
            background: BubdongColors.actionPrimary,
            border: Colors.transparent,
            text: BubdongColors.textOnAction,
          ),
          pressed: _primaryPressed,
          loading: _primaryLoading,
          disabled: _filledDisabled,
        );
      case BubdongButtonVariant.toneMedium:
        return _ButtonSpec(
          height: 80,
          paddingX: BubdongSpacing.s44,
          iconGap: BubdongSpacing.s12, // 홈 이용 대장 조회 아이콘 간격
          borderWidth: 4,
          radius: BubdongRadius.r40All,
          textStyle: BubdongTypography.buttonBold,
          normal: const _ButtonColors(
            background: Colors.transparent,
            border: BubdongColors.brandPrimary,
            text: BubdongColors.textAccentDark,
          ),
          pressed: _ButtonColors(
            background: BubdongColors.bgSurface,
            border: BubdongColors.actionPrimaryPressed,
            text: BubdongColors.textAccentDark,
            shadows: [BubdongShadow.buttonGlow],
          ),
          loading: const _ButtonColors(
            background: Colors.transparent,
            border: BubdongColors.actionPrimaryPressed,
            text: BubdongColors.textAccentDark,
          ),
          disabled: _outlinedDisabled,
        );
      case BubdongButtonVariant.yellowMedium:
        return const _ButtonSpec(
          height: 80,
          paddingX: BubdongSpacing.s44,
          borderWidth: 4,
          radius: BubdongRadius.r40All,
          textStyle: BubdongTypography.buttonBold,
          normal: _ButtonColors(
            background: BubdongColors.actionSecondary,
            border: Colors.transparent,
            text: BubdongColors.textPrimary,
          ),
          disabled: _filledDisabled,
        );
      case BubdongButtonVariant.blueMedium:
        return const _ButtonSpec(
          height: 80,
          paddingX: BubdongSpacing.s44,
          borderWidth: 4,
          radius: BubdongRadius.r40All,
          textStyle: BubdongTypography.buttonBold,
          normal: _ButtonColors(
            background: BubdongColors.actionBlue,
            border: Colors.transparent,
            text: BubdongColors.textOnPrimary,
          ),
          disabled: _filledDisabled,
        );
      case BubdongButtonVariant.outlineSmall:
        return const _ButtonSpec(
          height: 66,
          width: 160,
          paddingX: 0,
          borderWidth: 2,
          radius: BubdongRadius.r30All,
          textStyle: BubdongTypography.buttonSemibold,
          normal: _ButtonColors(
            background: Colors.transparent,
            border: BubdongColors.brandPrimary,
            text: BubdongColors.textAccent,
          ),
          disabled: _outlinedDisabled,
        );
    }
  }
}
