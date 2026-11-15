import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/check_in_result.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/gender.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/sign_up_request.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/user_repository.dart';

class RemoteUserRepository implements UserRepository {
  final BubdongApiClient _client;

  const RemoteUserRepository(this._client);

  @override
  Future<int?> findUserId(String phone) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/check-in',
      queryParameters: {'phone': phone},
    );
    return response.data!['userId'] as int?;
  }

  /// `POST /check-in/sign-up`
  @override
  Future<CheckInResult> signUp(
    SignUpRequest request,
    List<int> purposeIds,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/check-in/sign-up',
      data: {
        'name': request.name,
        'gender': _toGenderValue(request.gender!),
        'phone': request.phone,
        'birthYMD': _toBirthYmd(request.birthDate!),
        'grade': request.grade,
        'school': request.school,
        'route': request.route,
        'address': request.address,
        'privacyAgreed': request.privacyAgreed,
        'purpose': purposeIds,
      },
    );
    return _toCheckInResult(response.data!);
  }

  /// `POST /check-in`
  @override
  Future<CheckInResult> checkIn(int userId, List<int> purposeIds) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/check-in',
      data: {'userId': userId, 'purpose': purposeIds},
    );
    return _toCheckInResult(response.data!);
  }

  /// 회원가입·방명록 작성 응답 → 앱의 CheckInResult (두 API 응답 모양이 같음)
  CheckInResult _toCheckInResult(Map<String, dynamic> json) {
    return CheckInResult(
      logId: json['logId'] as int,
      pcForm: json['pcForm'] as bool,
      singForm: json['singForm'] as bool,
      pingForm: json['pingForm'] as bool,
    );
  }

  /// Gender.male → 'MAN'
  String _toGenderValue(Gender gender) {
    return switch (gender) {
      Gender.male => 'MAN',
      Gender.female => 'WOMAN',
    };
  }

  /// 2008-05-04 형식 (서버가 이 값으로 나이 구간을 계산)
  String _toBirthYmd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
