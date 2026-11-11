import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/school_repository.dart';

/// 서버의 학교 검색. 500 같은 에러는 DioException 그대로 위로 올라감
class RemoteSchoolRepository implements SchoolRepository {
  final BubdongApiClient _client;

  const RemoteSchoolRepository(this._client);

  /// `GET /check-in/school?name=&page=`
  @override
  Future<SchoolSearchResult> search({required String name, int page = 1}) async {
    // ① 서버에 요청
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/check-in/school',
      queryParameters: {'name': name, 'page': page},
    );
    final json = response.data!;

    // ② JSON → School 목록
    final schools = (json['schools'] as List)
        .map((item) => _toSchool(item as Map<String, dynamic>))
        .toList();

    // ③ 결과로 묶어서 돌려주기
    return SchoolSearchResult(
      schools: schools,
      hasNext: json['hasNext'] as bool,
    );
  }

  /// 서버 학교 하나 → 앱의 School
  School _toSchool(Map<String, dynamic> json) {
    return School(
      code: json['schoolCode'] as String,
      name: json['schoolName'] as String,
      type: _toSchoolType(json['schoolType'] as String),
      address: json['address'] as String,
    );
  }

  /// 서버 글자 'HIGH' → SchoolType.high
  SchoolType _toSchoolType(String value) {
    return switch (value) {
      'ELEMENTARY' => SchoolType.elementary,
      'MIDDLE' => SchoolType.middle,
      'HIGH' => SchoolType.high,
      _ => SchoolType.other,   // 그 밖의 값은 전부 other
    };
  }
}