import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/visitor_type.dart';

/// 방명록에 남은 한 사람의 오늘 기록
class GuestbookEntry {
  const GuestbookEntry({
    required this.id,
    required this.name,
    required this.visitorType,
    required this.usedTime,
    required this.facilities,
    this.completedFacilities = const {},
  });

  final int id; // 기록 구분 (어른은 이름이 모두 '성인'이라 이름으로 못 나눔)
  final String name; // 어른은 '성인'
  final VisitorType visitorType; // 아이·어른 구분 (이름 글자로 나누지 않음)
  final Duration usedTime;
  final List<Facility> facilities; // 오늘 고른 이용대장

  /// 이미 다 쓴 이용대장 (나머지는 이용 중)
  final Set<Facility> completedFacilities;

  GuestbookEntry copyWith({List<Facility>? facilities}) {
    return GuestbookEntry(
      id: id,
      name: name,
      visitorType: visitorType,
      usedTime: usedTime,
      facilities: facilities ?? this.facilities,
      completedFacilities: completedFacilities,
    );
  }
}
