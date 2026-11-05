import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/server_date_format.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/sign_up_repository.dart';

/// 서버의 회원가입. 예약 칸 409 말고는 Dio가 던지는 [DioException] 그대로 올라갑니다.
class RemoteSignUpRepository implements SignUpRepository {
  final ApiClient _client;

  const RemoteSignUpRepository(this._client);

  /// `POST /user/sign-up`.
  @override
  Future<void> signUp({
    required String name,
    required Gender gender,
    required String phone,
    required DateTime birthDate,
    required String residence,
    required String purpose,
    required int maleCount,
    required int femaleCount,
    required DateTime visitTime,
    String? reservationTime,
  }) async {
    try {
      await _client.dio.post<void>(
        '/user/sign-up',
        data: {
          'name': name,
          'gender': gender.serverValue,
          'phone': PhoneNumberFormatter.format(phone),
          'maleCount': maleCount,
          'femaleCount': femaleCount,
          'birthYMD': ServerDateFormat.date(birthDate),
          'residence': residence,
          // 동의하지 않으면 폼 검사에서 막히므로 여기까지 오면 항상 동의한 것입니다.
          'privacyAgreed': true,
          'purpose': purpose,
          'visitTime': ServerDateFormat.dateTime(visitTime),
          'reservationTime': ?reservationTime,
        },
      );
    } on DioException catch (e) {
      if (RemoteReservationRepository.isSlotTaken(e)) {
        throw const SlotTakenException();
      }
      rethrow;
    }
  }
}

final signUpRepositoryProvider = Provider<SignUpRepository>((ref) {
  return RemoteSignUpRepository(ref.watch(apiClientProvider));
});
