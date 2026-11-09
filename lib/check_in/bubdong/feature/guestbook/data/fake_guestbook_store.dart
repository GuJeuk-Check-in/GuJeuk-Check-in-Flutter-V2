import 'package:flutter/foundation.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/visitor_type.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_entry.dart';

/// 방명록 가짜 기록 (앱이 켜져 있는 동안만 유지)
// TODO: API 연결 시 서버 조회·저장으로 교체
class FakeGuestbookStore {
  FakeGuestbookStore._();

  static final entries = ValueNotifier<List<GuestbookEntry>>(const [
    GuestbookEntry(
      id: 1,
      name: '김하늘',
      visitorType: VisitorType.child,
      usedTime: Duration(minutes: 80),
      facilities: [Facility.internet, Facility.tableTennis, Facility.rest],
      completedFacilities: {Facility.tableTennis},
    ),
    GuestbookEntry(
      id: 2,
      name: '성인',
      visitorType: VisitorType.adult,
      usedTime: Duration(minutes: 30),
      facilities: [Facility.rest],
    ),
    GuestbookEntry(
      id: 3,
      name: '이바다',
      visitorType: VisitorType.child,
      usedTime: Duration(minutes: 45),
      facilities: [Facility.boardGame, Facility.karaoke],
    ),
    GuestbookEntry(
      id: 4,
      name: '박구름',
      visitorType: VisitorType.child,
      usedTime: Duration(minutes: 100),
      facilities: [Facility.bangka],
    ),
    GuestbookEntry(
      id: 5,
      name: '성인',
      visitorType: VisitorType.adult,
      usedTime: Duration(minutes: 60),
      facilities: [Facility.club, Facility.rest],
    ),
    GuestbookEntry(
      id: 6,
      name: '최별',
      visitorType: VisitorType.child,
      usedTime: Duration(minutes: 20),
      facilities: [Facility.karaoke],
    ),
  ]);

  /// 기록의 이용대장을 바꿔 저장 (목록 화면도 바로 갱신됨)
  static void saveFacilities(int id, List<Facility> facilities) {
    entries.value = [
      for (final entry in entries.value)
        entry.id == id ? entry.copyWith(facilities: facilities) : entry,
    ];
  }
}
