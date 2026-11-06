import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/local_outbox_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_ha_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_residence_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/ha_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/residence_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/sign_up_repository.dart';

final signUpRepositoryProvider = Provider<SignUpRepository>((ref) {
  return RemoteSignUpRepository(ref.watch(apiClientProvider));
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return RemoteReservationRepository(ref.watch(apiClientProvider));
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return RemoteCheckInRepository(ref.watch(apiClientProvider));
});

final residenceRepositoryProvider = Provider<ResidenceRepository>((ref) {
  return RemoteResidenceRepository(ref.watch(apiClientProvider));
});

final haRepositoryProvider = Provider<HaRepository>((ref) {
  return RemoteHaRepository(ref.watch(apiClientProvider));
});

final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  return LocalOutboxRepository();
});
