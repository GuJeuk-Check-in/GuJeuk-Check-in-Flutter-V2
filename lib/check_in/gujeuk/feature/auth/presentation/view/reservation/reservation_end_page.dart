import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/base_scaffold.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/spacing.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/presentation/home_page.dart';

class ReservationEndPage extends StatelessWidget {
  final ReservationInfo? reservation;

  const ReservationEndPage({super.key, this.reservation});

  @override
  Widget build(BuildContext context) {
    // 좁은 화면에서는 바깥 여백을 줄여 예약 정보가 들어갈 폭을 남깁니다.
    final isNarrow = MediaQuery.sizeOf(context).width < 800;
    return BaseScaffold(
      child: Padding(
        padding: EdgeInsets.all(
          isNarrow ? GujeukSpacing.s20 : GujeukSpacing.s100,
        ),
        child: DoneBox(
          title: reservation == null ? '시설 이용 신청이 끝났어' : '시설 예약이 끝났어!',
          smallTitle: reservation == null
              ? '우리 시설을 바로 이용해도 좋아~!'
              : '예약한 시간에 맞춰 놀러 와줘~!',
          buttonTitle: reservation == null ? '다 했어요!' : '처음으로!',
          isReservation: reservation,
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          ),
        ),
      ),
    );
  }
}
