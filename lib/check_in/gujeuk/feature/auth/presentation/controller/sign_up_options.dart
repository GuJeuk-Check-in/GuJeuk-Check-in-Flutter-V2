import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_residence_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';

/// 실패하면 화면에 문구와 다시 시도 버튼을 띄우므로 Riverpod의 자동 재시도는 끕니다.
Duration? _noRetry(int _, Object _) => null;

/// 카드로 보여줄 방문 목적과, 그중 예약이 필요한 시설.
class PurposeCatalog {
  final List<VisitPurpose> purposes;

  /// 예약이 필요한 목적 이름들. 고르면 시간도 골라야 합니다.
  final Set<String> reservable;

  const PurposeCatalog({required this.purposes, required this.reservable});

  /// 고른 목적이 예약이 필요한 시설이라 시간도 골라야 하는지.
  bool needsTime(String? purpose) => reservable.contains(purpose);

  /// 본인을 뺀 동행 최대 인원. 정원이 없는 시설이면 null입니다.
  int? maxCompanions(String? purpose) {
    final maxPeople = purposes
        .where((p) => p.purpose == purpose)
        .firstOrNull
        ?.maxPeople;
    return maxPeople == null ? null : maxPeople - 1;
  }
}

/// 전체 방문 목적과 예약이 필요한 시설을 함께 받습니다.
/// 예약이 필요 없는 목적도 카드로 보이고, 고르면 시간 없이 제출할 수 있습니다.
/// 예약 시설을 모르면 예약 시설이 시간 없이 기록될 수 있어, 둘 중 하나만 실패해도 실패로 둡니다.
final purposeCatalogProvider = FutureProvider.autoDispose<PurposeCatalog>((
  ref,
) async {
  final reservations = ref.watch(reservationRepositoryProvider);
  final (all, reservable) = await (
    reservations.fetchVisitPurposes(),
    reservations.fetchReservablePurposes(),
  ).wait;
  return PurposeCatalog(
    purposes: all,
    reservable: {for (final p in reservable) p.purpose},
  );
}, retry: _noRetry);

/// 시설에서 아직 예약할 수 있는 시간(`HH:mm`).
/// 시설마다 따로 두므로, 응답을 기다리는 사이 다른 시설을 골라도 늦게 온 응답이 섞이지 않습니다.
final availableTimesProvider = FutureProvider.autoDispose
    .family<Set<String>, String>((ref, purpose) async {
      final times = await ref
          .watch(reservationRepositoryProvider)
          .fetchAvailableTimes(purpose);
      return times.toSet();
    }, retry: _noRetry);

/// 거주지 모달에 띄울 동네 이름들.
final residencesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(residenceRepositoryProvider).fetchResidences(),
  retry: _noRetry,
);
