import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:flutter/services.dart';

class BubdongInput extends StatefulWidget {
  const BubdongInput({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.enabled = true,
    this.validator,
    this.isLoading = false,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
  });

  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool isLoading;

  @override
  State<BubdongInput> createState() => _BubdongInputState();
}

class _BubdongInputState extends State<BubdongInput> {
  // 알약 모양 테두리를 만드는 함수. color가 null이면 테두리 없음
  OutlineInputBorder _border(Color? color) {
    return OutlineInputBorder(
      borderRadius: BubdongRadius.r9999All,
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: widget.controller?.text, // 처음 값
      validator: widget.validator, // 밖에서 받은 검사 규칙
      builder: (field) {
        final hasError = field.hasError; // 지금 에러인지

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 질문 글자
            Text(widget.label, style: BubdongTypography.fieldLabel),
            const SizedBox(height: BubdongLayout.fieldLabelGap),

            // 입력칸 + 그림자
            Container(
              height: BubdongLayout.fieldHeight, // 높이 고정, 글자는 세로 가운데
              decoration: BoxDecoration(
                borderRadius: BubdongRadius.r9999All,
                boxShadow: !widget.enabled
                    ? [] // 비활성: 그림자 없음
                    : hasError
                    ? [BubdongShadow.inputError] // 에러: 빨강
                    : [BubdongShadow.inputDefault], // 그 외: 주황
              ),
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType, // 받은 값을 실제 입력칸에 넘김
                inputFormatters: widget.inputFormatters,
                enabled: widget.enabled,
                expands: true, // 고정 높이를 꽉 채움
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                onChanged: field.didChange,
                // 입력할 때마다 FormField에 알려줌
                style: BubdongTypography.placeHolder.copyWith(
                  color: BubdongColors.textPrimary,
                ),
                decoration: InputDecoration(
                  suffixText: widget.suffixText,
                  suffixStyle: BubdongTypography.placeHolder.copyWith(
                    color: BubdongColors.textPrimary,
                  ),
                  filled: true,
                  fillColor: widget.enabled
                      ? BubdongColors.bgFieldSelected
                      : BubdongColors.bgFieldDisabled,
                  hoverColor: Colors.transparent,
                  // 마우스 올려도 배경 안 바뀜
                  hintText: widget.hintText,
                  hintStyle: BubdongTypography.placeHolder.copyWith(
                    color: widget.enabled
                        ? BubdongColors.textPlaceholder
                        : BubdongColors.textFieldDisabled,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: BubdongSpacing.s32,
                  ),
                  enabledBorder: _border(
                    hasError
                        ? BubdongColors.borderError
                        : null, // 에러면 빨강, 아니면 없음
                  ),
                  focusedBorder: _border(
                    hasError
                        ? BubdongColors.borderError
                        : BubdongColors.brandPrimary, // 에러면 빨강, 아니면 주황
                  ),
                  disabledBorder: _border(null), // 비활성: 테두리 없음
                ),
              ),
            ),

            // 에러 글자 (에러일 때만)
            if (hasError) ...[
              const SizedBox(height: BubdongSpacing.s10), // 입력칸과 에러 글자 사이 (Figma 입력/Wrong)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BubdongSpacing.s4,
                ),
                child: Text(
                  field.errorText!,
                  style: BubdongTypography.label.copyWith(
                    color: BubdongColors.textError,
                  ),
                ),
              ),
            ],

            // 로딩 줄 (로딩일 때만)
            if (widget.isLoading) ...[
              const SizedBox(height: BubdongSpacing.s12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BubdongSpacing.s4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BubdongColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s8),
                    Text(
                      '로딩 중..',
                      style: BubdongTypography.placeHolder.copyWith(
                        color: BubdongColors.textAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}