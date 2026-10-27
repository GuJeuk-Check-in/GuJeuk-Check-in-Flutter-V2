import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reserved_slot.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 서버가 붙기 전 퍼블리싱용 가짜 응답. API 명세의 응답 모양을 그대로 따릅니다.
class FakeReservationRepository implements ReservationRepository {
  /// 로딩 화면을 볼 수 있게 응답을 늦춥니다.
  final Duration delay;

  const FakeReservationRepository({
    this.delay = const Duration(milliseconds: 500),
  });

  static const _visitPurposes = [
    {'id': 1, 'purpose': '친친마루(게임, 독서 등)'},
    {'id': 2, 'purpose': '난장마루(노래방 최대 4명)'},
    {'id': 3, 'purpose': '잔치마루(노래방 최대 8명)'},
    {'id': 4, 'purpose': '창작마루(방송실)'},
    {'id': 5, 'purpose': '통통마루(댄스연습실)'},
  ];

  // 예약 없이 쓰는 경우도 볼 수 있게 친친마루는 뺐습니다.
  static const _reservablePurposeIds = {2, 3, 4, 5};

  static const _reservedSlots = [
    {'purpose': '난장마루(노래방 최대 4명)', 'startTime': '11:30:00'},
    {'purpose': '난장마루(노래방 최대 4명)', 'startTime': '14:30:00'},
    {'purpose': '난장마루(노래방 최대 4명)', 'startTime': '15:30:00'},
    {'purpose': '잔치마루(노래방 최대 8명)', 'startTime': '10:30:00'},
    {'purpose': '창작마루(방송실)', 'startTime': '13:30:00'},
    {'purpose': '창작마루(방송실)', 'startTime': '17:30:00'},
  ];

  @override
  Future<List<VisitPurpose>> fetchVisitPurposes() async {
    await Future<void>.delayed(delay);
    return _visitPurposes.map(VisitPurpose.fromJson).toList();
  }

  @override
  Future<List<VisitPurpose>> fetchReservablePurposes() async {
    await Future<void>.delayed(delay);
    return _visitPurposes
        .where((json) => _reservablePurposeIds.contains(json['id']))
        .map(VisitPurpose.fromJson)
        .toList();
  }

  @override
  Future<List<ReservedSlot>> fetchReservedSlots() async {
    await Future<void>.delayed(delay);
    return _reservedSlots.map(ReservedSlot.fromJson).toList();
  }
}
