/// 학교를 안 다닐 때 보내는 학교 이름 (명세: 무교 + 학년 0)
const noSchoolName = '무교';

/// 학교 검색 팝업에서 고른 결과 (학교 안 다님이면 type이 null)
typedef SchoolPick = ({String name, SchoolType? type});

enum SchoolType { elementary, middle, high, other } //초, 중, 고교 타입 enum

class School {
  const School({
    required this.type,
    required this.code,
    required this.address,
    required this.name,
  });

  final String code;
  final String name;
  final SchoolType type;
  final String address;
}

class SchoolSearchResult {
  const SchoolSearchResult({required this.schools, required this.hasNext});

  final List<School> schools;
  final bool hasNext;
}

abstract class SchoolRepository {
  Future<SchoolSearchResult> search({required String name, int page = 1});
}