enum SchoolType { elementary, middle, high, other }

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