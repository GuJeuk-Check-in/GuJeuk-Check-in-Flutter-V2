/// 장애에 대비해 저장해 둔 접수를 서버로 보냅니다. 실패하면 예외를 던집니다.
abstract interface class HaRepository {
  /// 서버와 DB가 요청을 받을 수 있는 상태인지. 연결이 안 되면 false입니다.
  Future<bool> isReady();

  /// 회원 id를 아는 방문 기록을 보냅니다. [body]는 저장해 둔 JSON입니다.
  Future<void> sendLog(String body);

  /// 처음 왔거나 회원인지 모르는 방문을 보냅니다. [body]는 저장해 둔 JSON입니다.
  Future<void> sendSignUp(String body);
}
