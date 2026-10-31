import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/domain/visitor_repository.dart';

/// 서버가 붙기 전 퍼블리싱용 가짜 응답.
class FakeVisitorRepository implements VisitorRepository {
  /// 로딩 화면을 볼 수 있게 응답을 늦춥니다.
  final Duration delay;

  const FakeVisitorRepository({this.delay = const Duration(milliseconds: 500)});

  // 이 이름을 넣으면 재방문, 그 밖의 이름은 첫 방문으로 봅니다.
  static const _registeredUserIds = {'ff': 1, '김철수': 2, '이영희': 3};

  @override
  Future<int?> findUserId(String name) async {
    await Future<void>.delayed(delay);
    return _registeredUserIds[name];
  }
}
