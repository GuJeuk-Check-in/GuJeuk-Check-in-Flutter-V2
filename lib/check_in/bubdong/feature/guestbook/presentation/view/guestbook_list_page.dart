import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/data/remote_purpose_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/facility.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/visitor_type.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/facility_select_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/data/remote_guestbook_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_entry.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/domain/guestbook_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/purpose_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/guestbook/presentation/widgets/guestbook_item.dart';

/// 오늘 방명록을 남긴 사람 목록 (Figma 방명록 리스트)
class GuestbookListPage extends StatefulWidget {
  const GuestbookListPage({super.key});

  @override
  State<GuestbookListPage> createState() => _GuestbookListPageState();
}

class _GuestbookListPageState extends State<GuestbookListPage> {
  final _guestbookRepository = RemoteGuestbookRepository(bubdongApiClient);
  final _purposeRepository = RemotePurposeRepository(bubdongApiClient);

  List<GuestbookEntry> _entries = [];
  bool _isLoading = true; // 불러오는 중
  String? _error; // 실패했을 때 보여줄 문구

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 방명록과 이용대장 목록을 받아 화면용 기록으로 바꿈
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _guestbookRepository.fetchAll(), // 30개 넘으면 다음 페이지까지
        _purposeRepository.fetchAll(),
      ]);
      if (!mounted) return; // 기다리는 동안 화면을 나갔으면 멈춤
      final logs = results[0] as List<GuestbookLog>;
      final purposes = results[1] as List<Purpose>;
      // 서버 이용대장 id → 앱 이용대장
      final facilityById = {
        for (final purpose in purposes)
          purpose.id: ?Facility.byName(purpose.name),
      };
      setState(() {
        _entries = [
          for (final log in logs)
            GuestbookEntry(
              id: log.id,
              name: log.name,
              // TODO(bubdong): 응답에 아이·어른 구분이 없어 모두 아이로 봄 (이름 글자로 나누지 않음)
              visitorType: VisitorType.child,
              usedTime: Duration(minutes: log.organRemainTime),
              facilities: [
                for (final id in log.purposeIds) ?facilityById[id],
              ],
              // TODO(bubdong): 다 쓴 이용대장 값이 응답에 없어 모두 이용 중으로 보임
            ),
        ];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '방명록을 불러오지 못했어요. 잠시 후 다시 시도해주세요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 기록을 눌러 이용대장 선택으로. 돌아오면 바뀐 기록을 다시 불러옴
  Future<void> _open(GuestbookEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        // 어른이면 어른 목록(10개)·신청서 없이 완료
        builder: (_) => FacilitySelectPage(
          visitorType: entry.visitorType,
          guest: entry,
        ),
      ),
    );
    if (!mounted) return;
    _load();
  }

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
          _buildList(),
          const SizedBox(height: BubdongSpacing.s40), // 마지막 카드가 화면 끝에 붙지 않게
        ],
      ),
    );
  }

  /// 목록 자리: 불러오는 중 / 실패 / 기록 없음 / 목록
  Widget _buildList() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: BubdongColors.brandPrimary);
    }
    final message =
        _error ?? (_entries.isEmpty ? '아직 방명록을 남긴 친구가 없어요' : null);
    if (message != null) {
      return Text(
        message,
        style: BubdongTypography.bodySm.copyWith(
          color: BubdongColors.textSecondary,
        ),
      );
    }
    return ConstrainedBox(
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
              onTap: () => _open(entry),
            ),
        ],
      ),
    );
  }
}
