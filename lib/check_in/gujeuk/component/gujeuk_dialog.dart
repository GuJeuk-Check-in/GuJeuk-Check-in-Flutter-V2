import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

/// Figma `Dialog` · 확인 모달 (처음 방문 확인, 동명이인 확인 등).
/// 화면에 띄울 때는 [GujeukDialog.show]를 사용합니다.
class GujeukDialog extends StatelessWidget {
  final String title;
  final String description;
  final GujeukIcons icon;
  final String cancelLabel;
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
      builder: (context) => Center(
        child: Material(
          type: MaterialType.transparency,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 528,
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
          Row(
            children: [
              Expanded(
                child: GujeukButton(
                  label: cancelLabel,
                  variant: GujeukButtonVariant.neutralMedium,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: GujeukSpacing.s20),
              Expanded(
                child: GujeukButton(
                  label: confirmLabel,
                  variant: GujeukButtonVariant.primaryMedium,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
