import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

/// Figma `Dialog` · 확인 모달 (처음 방문 확인, 동명이인 확인 등).
/// 화면에 띄울 때는 [GujeukDialog.show]를 사용합니다.
class GujeukDialog extends StatelessWidget {
  final String title;
  final String description;
  final GujeukIcons icon;

  /// null이면 취소 버튼 없이 확인 버튼만 둡니다 (알림 모달).
  final String? cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  /// Header 아래에 넣을 위젯 (예: [GujeukInput]).
  final Widget? child;

  const GujeukDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon = GujeukIcons.wave,
    this.cancelLabel = '아니요',
    this.confirmLabel = '예',
    this.onCancel,
    this.onConfirm,
    this.child,
  });

  /// 예 → true, 아니요 → false, 바깥 영역을 눌러 닫으면 null을 반환합니다.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    GujeukIcons icon = GujeukIcons.wave,
    String cancelLabel = '아니요',
    String confirmLabel = '예',
    Widget? child,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GujeukModalFrame(
        child: GujeukDialog(
          title: title,
          description: description,
          icon: icon,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
          child: child,
        ),
      ),
    );
  }

  /// 확인 버튼 하나만 있는 알림 모달. 확인을 누르거나 바깥을 눌러 닫으면 끝납니다.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String description,
    GujeukIcons icon = GujeukIcons.wave,
    String confirmLabel = '확인',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => GujeukModalFrame(
        child: GujeukDialog(
          title: title,
          description: description,
          icon: icon,
          cancelLabel: null,
          confirmLabel: confirmLabel,
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 넓은 화면에서는 528, 좁은 화면에서는 화면 폭에 맞춰 줄어듭니다.
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 528),
      padding: const EdgeInsets.symmetric(
        horizontal: GujeukSpacing.s48,
        vertical: GujeukSpacing.s40,
      ),
      decoration: BoxDecoration(
        color: GujeukColors.bgSurface,
        borderRadius: GujeukRadius.mdAll,
        border: Border.all(color: GujeukColors.borderCard),
        boxShadow: GujeukShadows.modal,
      ),
      // 키보드가 올라와 남은 높이가 모자라면 모달 안에서 스크롤합니다.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GujeukIcon(icon),
            const SizedBox(height: GujeukSpacing.s20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GujeukTypography.headingSm.copyWith(
                color: GujeukColors.textBrand,
              ),
            ),
            const SizedBox(height: GujeukSpacing.s8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GujeukTypography.bodySm.copyWith(
                color: GujeukColors.textTertiary,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: GujeukSpacing.s32),
              child!,
            ],
            const SizedBox(height: GujeukSpacing.s32),
            // 한쪽 라벨만 두 줄이 되어도 두 버튼 높이를 맞춥니다.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (cancelLabel case final cancelLabel?) ...[
                    Expanded(
                      child: GujeukButton(
                        label: cancelLabel,
                        variant: GujeukButtonVariant.neutralMedium,
                        onPressed: onCancel,
                      ),
                    ),
                    const SizedBox(width: GujeukSpacing.s20),
                  ],
                  Expanded(
                    child: GujeukButton(
                      label: confirmLabel,
                      variant: GujeukButtonVariant.primaryMedium,
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 모달을 화면 가운데 띄우되, 화면 키보드가 올라오면 키보드 위 남은 공간의 가운데로 올립니다.
/// 좁은 화면에서도 모달이 화면 끝에 붙지 않게 바깥 여백을 둡니다.
class GujeukModalFrame extends StatelessWidget {
  final Widget child;

  const GujeukModalFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding:
          MediaQuery.viewInsetsOf(context) +
          const EdgeInsets.all(GujeukSpacing.s20),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}
