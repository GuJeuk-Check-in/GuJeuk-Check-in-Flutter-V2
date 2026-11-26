/// 회원가입 때 고르는 거주지 목록. 실패하면 예외를 던집니다.
abstract interface class ResidenceRepository {
  /// 거주지 이름들. 회원가입에는 이 이름을 그대로 보냅니다.
  Future<List<String>> fetchResidences();
}
