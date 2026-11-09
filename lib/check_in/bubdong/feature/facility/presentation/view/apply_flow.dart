import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/apply_done_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/computer_apply_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/people_apply_page.dart';

/// 고른 이용대장 중 신청서가 필요한 것을 차례대로 띄움
void openNextApplication(
  BuildContext context,
  List<Facility> queue, {
  Facility? current, // 방금 쓴 신청서 (완료 화면 제목에 씀)
}) {
  if (queue.isEmpty) {
    // 남은 신청서가 없으면 신청 완료 화면
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ApplyDonePage(lastFacility: current)),
    );
    return;
  }

  final next = queue.first;
  final remaining = queue.sublist(1);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => next == Facility.internet
          ? ComputerApplyPage(remaining: remaining) // 좌석을 고르는 신청서
          : PeopleApplyPage(facility: next, remaining: remaining), // 인원을 적는 신청서
    ),
  );
}
