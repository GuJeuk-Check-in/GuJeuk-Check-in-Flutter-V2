import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/people_apply_page.dart';

/// 고른 이용대장 중 신청서가 필요한 것을 차례대로 띄움
void openNextApplication(BuildContext context, List<Facility> queue) {
  // TODO: 인터넷 신청서 화면 만들면 연결 (작업 6-2), 지금은 건너뜀
  final next = queue.where((f) => f != Facility.internet).toList();

  if (next.isEmpty) {
    // TODO: 신청 완료 화면 연결 (작업 7)
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PeopleApplyPage(
        facility: next.first,
        remaining: next.sublist(1),
      ),
    ),
  );
}
