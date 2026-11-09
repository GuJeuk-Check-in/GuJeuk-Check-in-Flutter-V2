import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/facility_select_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_entry.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/presentation/widgets/guestbook_item.dart';

/// 오늘 방명록을 남긴 사람 목록 (Figma 방명록 리스트)
class GuestbookListPage extends StatelessWidget {
  const GuestbookListPage({super.key});

  // TODO: API 연결 시 교체
  static const _entries = [
    GuestbookEntry(
      name: '김하늘',
      usedTime: Duration(minutes: 80),
      facilities: [Facility.internet, Facility.tableTennis],
    ),
    GuestbookEntry(
      name: '성인',
      usedTime: Duration(minutes: 30),
      facilities: [Facility.rest],
    ),
    GuestbookEntry(
      name: '이바다',
      usedTime: Duration(minutes: 45),
      facilities: [Facility.boardGame, Facility.karaoke],
    ),
    GuestbookEntry(
      name: '박구름',
      usedTime: Duration(minutes: 100),
      facilities: [Facility.bangka],
    ),
    GuestbookEntry(
      name: '성인',
      usedTime: Duration(minutes: 60),
      facilities: [Facility.club, Facility.rest],
    ),
    GuestbookEntry(
      name: '최별',
      usedTime: Duration(minutes: 20),
      facilities: [Facility.karaoke],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 화면보다 길어지면 BubdongBaseScaffold 안에서 스크롤됨
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BubdongPageHeader(
            title: '방명록 리스트',
            subtitle: '내 이름을 눌러 방명록을 더 자세히 보거나 수정할 수 있어!',
          ),
          const SizedBox(height: BubdongSpacing.s40), // 헤더와 첫 카드 사이 (Figma)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: BubdongLayout.guestbookListWidth,
            ),
            child: Column(
              spacing: BubdongLayout.guestbookCardGap,
              children: [
                for (final entry in _entries)
                  GuestbookItem(
                    name: entry.name,
                    usedTime: entry.usedTime,
                    facilities: entry.facilities,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            FacilitySelectPage(guestName: entry.name),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s40), // 마지막 카드가 화면 끝에 붙지 않게
        ],
      ),
    );
  }
}
