import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';

/// 이용대장 선택 화면에 누가 들어왔는지
enum VisitorType {
  /// 아이들 방문 기록, 방명록
  child,

  /// 어른 방문 기록
  adult;

  /// 고를 수 있는 이용대장 (아이 8개, 어른 10개)
  List<Facility> get facilities => switch (this) {
        VisitorType.child => Facility.children,
        VisitorType.adult => Facility.adults,
      };

  /// 신청서를 쓰는지 (Figma 어른 흐름: 시설 고르기 → 바로 신청 완료)
  bool get writesApplication => this == VisitorType.child;
}
