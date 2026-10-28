import 'package:flutter/cupertino.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

class DoneBox extends StatelessWidget {
  final String title;
  final String smallTitle;
  final ReservationInfo? isReservation;
  final String buttonTitle;
  final void Function()? onPressed;

  const DoneBox({
    super.key,
    required this.title,
    required this.smallTitle,
    this.isReservation,
    required this.buttonTitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GujeukSpacing.s64),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GujeukRadius.xl),
        color: GujeukColors.bgSurface,
        boxShadow: GujeukShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GujeukIcon(GujeukIcons.checkCircle),
          const SizedBox(height: GujeukSpacing.s20),
          Text(
            title,
            style: GujeukTypography.titleLg.copyWith(
              color: GujeukColors.textBrand,
            ),
          ),
          const SizedBox(height: GujeukSpacing.s8),
          Text(
            smallTitle,
            style: GujeukTypography.headingMd.copyWith(
              color: GujeukColors.textTertiary,
            ),
          ),
          if (isReservation case final r?) ...[
            const SizedBox(height: GujeukSpacing.s48),
            _ReservationCard(info: r),
            const SizedBox(height: GujeukSpacing.s48),
            Text(
              '이용 시간이 끝나면 대표자 전화번호로 안내 문자를 보내줄게',
              style: GujeukTypography.bodyMd.copyWith(
                color: GujeukColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: GujeukSpacing.s80),
          Row(
            children: [
              Expanded(
                child: GujeukButton(
                  label: buttonTitle,
                  icon: GujeukIcons.party,
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReservationInfo {
  final String name;
  final String phone;
  final int maleCount;
  final int femaleCount;
  final String purpose;
  final String startTime;

  const ReservationInfo({
    required this.name,
    required this.phone,
    required this.maleCount,
    required this.femaleCount,
    required this.purpose,
    required this.startTime,
  });
}

class _ReservationCard extends StatelessWidget {
  final ReservationInfo info;

  const _ReservationCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GujeukSpacing.s48,
        vertical: GujeukSpacing.s36,
      ),
      decoration: BoxDecoration(
        color: GujeukColors.bgField,
        borderRadius: BorderRadius.circular(GujeukRadius.lg),
      ),
      child: Column(
        children: [
          _row('예약자', info.name),
          const SizedBox(height: GujeukSpacing.s20),
          _row('시설', info.purpose),
          const SizedBox(height: GujeukSpacing.s20),
          _row('시간', info.startTime),
          const SizedBox(height: GujeukSpacing.s20),
          _row('인원', '본인 + 남자${info.maleCount}명 · 여자${info.femaleCount}명'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GujeukTypography.headingMd.copyWith(
          color: GujeukColors.textTertiary,
        ),
      ),
      Text(value, style: GujeukTypography.headingMd.copyWith(color: GujeukColors.textPrimary)),
    ],
  );
}
