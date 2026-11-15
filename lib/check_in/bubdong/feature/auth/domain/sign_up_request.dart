import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/gender.dart';

/// 회원가입 화면들을 지나며 채우는 요청 (이용대장은 마지막에 따로 붙임)
class SignUpRequest {
  const SignUpRequest({
    required this.phone,
    this.name,
    this.gender,
    this.birthDate,
    this.school,
    this.grade,
    this.address,
    this.route,
    this.privacyAgreed = false,
  });

  final String phone; // 1단계에서 조회한 번호 (2단계에서 고칠 수 있음)
  final String? name;
  final Gender? gender;
  final DateTime? birthDate;
  final String? school;
  final int? grade;
  final String? address;
  final String? route; // 방문 경로 글자 (기타면 직접 적은 내용)
  final bool privacyAgreed;

  SignUpRequest copyWith({
    String? phone,
    String? name,
    Gender? gender,
    DateTime? birthDate,
    String? school,
    int? grade,
    String? address,
    String? route,
    bool? privacyAgreed,
  }) {
    return SignUpRequest(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      address: address ?? this.address,
      route: route ?? this.route,
      privacyAgreed: privacyAgreed ?? this.privacyAgreed,
    );
  }
}

/// 회원가입 결과 (가입과 함께 첫 방문 기록도 만들어짐)
class SignUpResult {
  const SignUpResult({
    required this.logId,
    required this.pcForm,
    required this.singForm,
    required this.pingForm,
  });

  final int logId; // 만들어진 방문 기록 번호
  final bool pcForm; // 컴퓨터 신청서를 써야 하는지
  final bool singForm; // 노래방 신청서를 써야 하는지
  final bool pingForm; // 탁구 신청서를 써야 하는지
}
