import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_facility_card.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';

/// 이용대장마다 카드 색 (Figma 이용대장 선택 화면)
extension FacilityCardColor on Facility {
  BubdongCardColor get cardColor => switch (this) {
        Facility.internet ||
        Facility.bangka ||
        Facility.workStudy =>
          BubdongCardColor.orange,
        Facility.tableTennis || Facility.karaoke => BubdongCardColor.mint,
        Facility.boardGame ||
        Facility.youthCouncil ||
        Facility.other =>
          BubdongCardColor.blue,
        Facility.rest || Facility.club => BubdongCardColor.pink,
      };
}
