import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';

/// 방명록에 남은 한 사람의 오늘 기록
class GuestbookEntry {
  const GuestbookEntry({
    required this.name,
    required this.usedTime,
    required this.facilities,
  });

  final String name; // 어른은 '성인'
  final Duration usedTime;
  final List<Facility> facilities;
}
