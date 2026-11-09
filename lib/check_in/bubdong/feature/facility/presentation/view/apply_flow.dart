import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_done_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/computer_apply_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/people_apply_page.dart';

/// 고른 이용대장 중 신청서가 필요한 것을 차례대로 띄움
void openNextApplication(
  BuildContext context,
  List<Facility> queue, {
  required List<Facility> selected, // 고른 이용대장 전체 (완료 화면 제목에 씀)
}) {
  if (queue.isEmpty) {
    // 남은 신청서가 없으면 신청 완료 화면 (뒤로가기로 신청서에 돌아가지 않게 홈만 남김)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ApplyDonePage(facilities: selected)),
      (route) => route.isFirst,
    );
    return;
  }

  final next = queue.first;
  final remaining = queue.sublist(1);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => next == Facility.internet
          ? ComputerApplyPage(remaining: remaining, selected: selected) // 좌석을 고르는 신청서
          : PeopleApplyPage(
              facility: next,
              remaining: remaining,
              selected: selected,
            ), // 인원을 적는 신청서
    ),
  );
}
