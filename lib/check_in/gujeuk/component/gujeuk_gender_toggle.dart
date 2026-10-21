import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

enum GujeukGender {
  male('남자', GujeukIcons.boy, GujeukIcons.boyInverse),
  female('여자', GujeukIcons.girl, GujeukIcons.girlInverse);

  const GujeukGender(this.label, this.icon, this.inverseIcon);

  final String label;
  final GujeukIcons icon;
  final GujeukIcons inverseIcon;
}

/// Figma `Gender Toggle` · 성별 선택. 선택 시 남자=teal, 여자=rose 배경.
class GujeukGenderToggle extends StatelessWidget {
  final GujeukGender gender;
  final bool selected;
  final VoidCallback? onTap;

  /// 기본은 부모 너비를 채웁니다. 고정하려면 값을 넘기세요.
  final double width;

  const GujeukGenderToggle({
    super.key,
    required this.gender,
    this.selected = false,
    this.onTap,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = gender == GujeukGender.male;
    final selectedBg = isMale
        ? GujeukColors.actionMale
        : GujeukColors.actionFemale;
    final shadow = switch ((isMale, selected)) {
      (true, false) => GujeukShadows.teal3d,
      (true, true) => GujeukShadows.teal3dStrong,
      (false, false) => GujeukShadows.rose3d,
      (false, true) => GujeukShadows.rose3dStrong,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s40),
        decoration: BoxDecoration(
          color: selected ? selectedBg : GujeukColors.bgField,
          borderRadius: GujeukRadius.fullAll,
          boxShadow: shadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GujeukIcon(selected ? gender.inverseIcon : gender.icon),
            const SizedBox(width: GujeukSpacing.s12),
            Text(
              gender.label,
              style: GujeukTypography.bodyMdMedium.copyWith(
                color: selected
                    ? GujeukColors.textInverse
                    : GujeukColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
