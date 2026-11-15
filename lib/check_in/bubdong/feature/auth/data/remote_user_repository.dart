import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/check_in_result.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/gender.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/school_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/visit_route.dart';
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
        'schoolType': _toSchoolTypeValue(request.schoolType),
        'route': _toRouteValue(request.route!),
        'routeDetail': request.routeDetail,
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

  /// VisitRoute.friend → 'FRIEND'
  String _toRouteValue(VisitRoute route) {
    return switch (route) {
      VisitRoute.friend => 'FRIEND',
      VisitRoute.parent => 'PARENT',
      VisitRoute.other => 'OTHER',
    };
  }

  /// SchoolType.high → 'HIGH' (검색 결과에서 받은 값을 그대로 돌려보냄)
  // TODO(bubdong): 학교 안 다님·직접 입력(null)과 other일 때 보낼 값 백엔드 확인 중 (지금은 null)
  String? _toSchoolTypeValue(SchoolType? type) {
    return switch (type) {
      SchoolType.elementary => 'ELEMENTARY',
      SchoolType.middle => 'MIDDLE',
      SchoolType.high => 'HIGH',
      SchoolType.other || null => null,
    };
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
