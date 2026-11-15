import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/gender.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/school_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/visit_route.dart';

/// 회원가입 화면들을 지나며 채우는 요청 (이용대장은 마지막에 따로 붙임)
class SignUpRequest {
  const SignUpRequest({
    required this.phone,
    this.name,
    this.gender,
    this.birthDate,
    this.school,
    this.schoolType,
    this.grade,
    this.address,
    this.route,
    this.routeDetail,
    this.privacyAgreed = false,
  });

  final String phone; // 1단계에서 조회한 번호 (2단계에서 고칠 수 있음)
  final String? name;
  final Gender? gender;
  final DateTime? birthDate;
  final String? school;
  final SchoolType? schoolType; // 검색으로 고른 학교만 (그 밖은 null)
  final int? grade;
  final String? address;
  final VisitRoute? route; // 방문 경로
  final String? routeDetail; // 기타일 때 직접 적은 내용
  final bool privacyAgreed;

  SignUpRequest copyWith({
    String? phone,
    String? name,
    Gender? gender,
    DateTime? birthDate,
    String? school,
    SchoolType? schoolType,
    int? grade,
    String? address,
    VisitRoute? route,
    String? routeDetail,
    bool? privacyAgreed,
  }) {
    return SignUpRequest(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      school: school ?? this.school,
      schoolType: schoolType ?? this.schoolType,
      grade: grade ?? this.grade,
      address: address ?? this.address,
      route: route ?? this.route,
      routeDetail: routeDetail ?? this.routeDetail,
      privacyAgreed: privacyAgreed ?? this.privacyAgreed,
    );
  }
}
