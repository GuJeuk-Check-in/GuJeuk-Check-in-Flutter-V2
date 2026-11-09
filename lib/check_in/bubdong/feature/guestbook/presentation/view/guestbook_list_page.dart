import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/facility_select_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/data/fake_guestbook_store.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/presentation/widgets/guestbook_item.dart';

/// 오늘 방명록을 남긴 사람 목록 (Figma 방명록 리스트)
class GuestbookListPage extends StatelessWidget {
  const GuestbookListPage({super.key});

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
            // 자동 저장으로 기록이 바뀌면 목록도 다시 그림
            child: ValueListenableBuilder(
              valueListenable: FakeGuestbookStore.entries,
              builder: (context, entries, _) => Column(
                spacing: BubdongLayout.guestbookCardGap,
                children: [
                  for (final entry in entries)
                    GuestbookItem(
                      name: entry.name,
                      usedTime: entry.usedTime,
                      facilities: entry.facilities,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          // 어른이면 어른 목록(10개)·신청서 없이 완료
                          builder: (_) => FacilitySelectPage(
                            visitorType: entry.visitorType,
                            guest: entry,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: BubdongSpacing.s40), // 마지막 카드가 화면 끝에 붙지 않게
        ],
      ),
    );
  }
}
