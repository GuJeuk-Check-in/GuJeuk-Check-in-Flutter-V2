import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

enum BubdongCardColor { orange, mint, blue, pink }
enum BubdongCardStatus { normal, selected, unavailable, completed, inUse }

class BubdongFacilityCard extends StatelessWidget {
  const BubdongFacilityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.detail,
    this.color = BubdongCardColor.orange,
    this.status = BubdongCardStatus.normal,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? detail;
  final BubdongCardColor color;
  final BubdongCardStatus status;
  final VoidCallback? onTap;

  Color get _tint {
    switch (color) {
      case BubdongCardColor.orange:
        return BubdongPalette.orange50;
      case BubdongCardColor.mint:
        return BubdongPalette.teal50;
      case BubdongCardColor.blue:
        return BubdongPalette.blue50;
      case BubdongCardColor.pink:
        return BubdongPalette.pink100;
    }
  }

  Color get _accent {
    switch (color) {
      case BubdongCardColor.orange:
        return BubdongPalette.orange500;
      case BubdongCardColor.mint:
        return BubdongPalette.teal500;
      case BubdongCardColor.blue:
        return BubdongPalette.blue500;
      case BubdongCardColor.pink:
        return BubdongPalette.pink500;
    }
  }

  _CardColors get _colors {
    switch (status) {
      case BubdongCardStatus.normal:
        return _CardColors(background: _tint, border: Colors.transparent);
      case BubdongCardStatus.selected:
        return _CardColors(
          background: BubdongColors.bgFieldSelected,
          border: _accent,
        );
      case BubdongCardStatus.unavailable:
        return const _CardColors(
          background: BubdongPalette.gray100,
          border: Colors.transparent,
        );
      case BubdongCardStatus.completed:
        return const _CardColors(
          background: BubdongPalette.teal200,
          border: BubdongPalette.teal500,
        );
      case BubdongCardStatus.inUse:
        return _CardColors(
          background: _tint,
          border: BubdongPalette.orange900,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final isUnavailable = status == BubdongCardStatus.unavailable;
    final shadowColor =
    status == BubdongCardStatus.normal ? _accent : colors.border;
    final smallText = BubdongTypography.label.copyWith(
      color: BubdongColors.textPlaceholder,
    );

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: BubdongSpacing.s12,
          vertical: BubdongSpacing.s24,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BubdongRadius.r15All,
          border: Border.all(color: colors.border, width: 2),
          boxShadow: isUnavailable
              ? []
              : [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.3),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: BubdongTypography.h5.copyWith(
                color: isUnavailable
                    ? BubdongColors.textPlaceholder
                    : BubdongColors.textPrimary,
              ),
            ),
            if (subtitle != null &&
                (status == BubdongCardStatus.normal ||
                    status == BubdongCardStatus.selected)) ...[
              const SizedBox(height: BubdongSpacing.s4),
              Text(subtitle!, style: smallText),
            ],
            if (isUnavailable) ...[
              const SizedBox(height: BubdongSpacing.s4),
              if (detail != null) Text(detail!, style: smallText),
              Text('자리 없음', style: smallText),
            ],
            if (status == BubdongCardStatus.completed) ...[
              const SizedBox(height: BubdongSpacing.s4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BubdongSpacing.s8,
                  vertical: BubdongSpacing.s2,
                ),
                decoration: BoxDecoration(
                  color: BubdongPalette.teal500.withValues(alpha: 0.25),
                  borderRadius: BubdongRadius.r9999All,
                ),
                child: Text(
                  '이용 완료',
                  style: BubdongTypography.label.copyWith(
                    color: BubdongPalette.teal500,
                  ),
                ),
              ),
            ],
            if (status == BubdongCardStatus.inUse) ...[
              const SizedBox(height: BubdongSpacing.s4),
              if (detail != null) Text(detail!, style: smallText),
              const SizedBox(height: BubdongSpacing.s2),
              Text(
                '이용 중',
                style: BubdongTypography.label.copyWith(
                  color: BubdongColors.textAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardColors {
  const _CardColors({
    required this.background,
    required this.border,
  });

  final Color background;
  final Color border;
}