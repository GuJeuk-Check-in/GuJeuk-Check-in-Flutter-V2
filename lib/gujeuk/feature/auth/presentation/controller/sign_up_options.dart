import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/data/option_cache.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/data/repository_providers.dart';
import 'package:gujeuk_check_in_flutter_v2/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 실패하면 화면에 문구와 다시 시도 버튼을 띄우므로 Riverpod의 자동 재시도는 끕니다.
Duration? _noRetry(int _, Object _) => null;

/// 카드로 보여줄 방문 목적과, 그중 예약이 필요한 시설.
class PurposeCatalog {
  final List<VisitPurpose> purposes;

  /// 예약이 필요한 목적 이름들. 고르면 시간도 골라야 합니다.
  /// 하위 목적을 고르는 목적은 담지 않고, 고른 하위의 [SubPurpose.needsReservation]으로 정합니다.
  final Set<String> reservable;

  const PurposeCatalog({required this.purposes, required this.reservable});

  /// 이름이 [purpose]인 목적. 서버는 기관 안에서 목적 이름이 겹치지 않게 둡니다.
  VisitPurpose? find(String? purpose) =>
      purposes.where((p) => p.purpose == purpose).firstOrNull;

  /// 고른 목적이 하위 목적을 하나 더 골라야 하는지.
  bool needsSubPurpose(String? purpose) =>
      find(purpose)?.needsSubPurpose ?? false;

  /// 고른 목적(과 하위 목적)이 예약이 필요한 시설이라 시간도 골라야 하는지.
  bool needsTime(String? purpose, [SubPurpose? subPurpose]) {
    if (needsSubPurpose(purpose)) return subPurpose?.needsReservation ?? false;
    return reservable.contains(purpose);
  }

  /// 본인을 뺀 동행 최대 인원. 하위 이름의 정원을 먼저 보고, 없으면 상위 이름을 봅니다.
  /// 정원이 없는 시설이면 null입니다.
  int? maxCompanions(String? purpose, [SubPurpose? subPurpose]) {
    final maxPeople = subPurpose?.maxPeople ?? find(purpose)?.maxPeople;
    return maxPeople == null ? null : maxPeople - 1;
  }

  /// 시간 조회와 예약을 보낼 단위. 목록에 없는 목적이면 null입니다.
  ReservationUnit? unitOf(String? purpose, [SubPurpose? subPurpose]) {
    final found = find(purpose);
    if (found == null) return null;
    return (
      purposeId: found.id,
      purpose: found.purpose,
      subPurposeId: found.needsSubPurpose ? subPurpose?.id : null,
    );
  }
}

/// 전체 방문 목적과 예약이 필요한 시설을 함께 받습니다.
/// 예약이 필요 없는 목적도 카드로 보이고, 고르면 시간 없이 제출할 수 있습니다.
/// 하위 목적이 하나도 없는 `SUB_INCLUDE`와 앱이 모르는 상태의 목적은 카드에서 뺍니다.
/// 서버에서 못 받으면 마지막으로 저장한 묶음을 씁니다.
/// 예약 시설을 모르면 예약 시설이 시간 없이 기록될 수 있어, 저장본도 없으면 실패로 둡니다.
final purposeCatalogProvider = FutureProvider.autoDispose<PurposeCatalog>((
  ref,
) async {
  final lists = await ref.watch(optionsLoaderProvider).purposeLists();
  return PurposeCatalog(
    // 하위가 없는 SUB_INCLUDE는 예약할 단위가 없어 고를 수 없게 뺍니다.
    purposes: [
      for (final p in lists.all)
        if (p.isSelectable) p,
    ],
    // 두 목록 중 하나라도 예약 시설로 보면 시간을 받습니다. 예약 시설이 시간 없이 접수되지 않게 합니다.
    reservable: {
      for (final p in lists.reservable) p.purpose,
      for (final p in lists.all)
        if (p.reservationStatus == PurposeReservationStatus.reservation)
          p.purpose,
    },
  );
}, retry: _noRetry);

/// 시설에서 아직 예약할 수 있는 시간(`HH:mm`).
/// 예약 단위마다 따로 두므로, 응답을 기다리는 사이 다른 시설을 골라도 늦게 온 응답이 섞이지 않습니다.
final availableTimesProvider = FutureProvider.autoDispose
    .family<Set<String>, ReservationUnit>((ref, unit) async {
      final times = await ref
          .watch(reservationRepositoryProvider)
          .fetchAvailableTimes(unit);
      return times.toSet();
    }, retry: _noRetry);

/// 거주지 모달에 띄울 동네 이름들.
final residencesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(optionsLoaderProvider).residences(),
  retry: _noRetry,
);
