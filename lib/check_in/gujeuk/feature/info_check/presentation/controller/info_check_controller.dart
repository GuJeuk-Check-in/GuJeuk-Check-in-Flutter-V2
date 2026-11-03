import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/data/remote_visitor_repository.dart';

/// 이름 확인 결과. 다이얼로그와 화면 이동은 화면이 맡습니다.
sealed class VisitorCheckResult {
  const VisitorCheckResult();
}

/// 다시 온 친구. 예약 화면으로 갑니다.
class VisitorFound extends VisitorCheckResult {
  final String name;
  final int userId;

  const VisitorFound({required this.name, required this.userId});
}

/// 이 이름의 회원이 없습니다. 처음 왔는지 한 번 물은 뒤 회원가입으로 갑니다.
class VisitorNotFound extends VisitorCheckResult {
  const VisitorNotFound();
}

/// 서버와 연결이 안 돼 회원인지 모릅니다. 정보를 모두 받아 기기에 저장합니다.
class VisitorCheckUnavailable extends VisitorCheckResult {
  final String name;

  const VisitorCheckUnavailable({required this.name});
}

/// 화면에 머뭅니다. 에러 문구는 이미 이름 칸 아래에 떠 있습니다.
class VisitorCheckStopped extends VisitorCheckResult {
  const VisitorCheckStopped();
}

/// 이름 칸 아래에 띄울 에러 문구. null이면 에러가 없습니다.
final infoCheckProvider =
    NotifierProvider.autoDispose<InfoCheckController, String?>(
      InfoCheckController.new,
    );

class InfoCheckController extends Notifier<String?> {
  /// 서버가 응답하지 않을 때 키오스크 앞에서 기다리는 최대 시간.
  static const _lookupLimit = Duration(seconds: 5);

  /// 조회하는 동안 버튼을 다시 눌러도 무시합니다.
  bool _isChecking = false;

  @override
  String? build() => null;

  /// 이름을 고치면 떠 있던 에러를 지웁니다.
  void clearError() {
    if (state != null) state = null;
  }

  /// 이름을 검사하고 서버에 등록된 방문자인지 조회합니다.
  Future<VisitorCheckResult> check(String rawName) async {
    if (_isChecking) return const VisitorCheckStopped();

    final name = rawName.trim();
    if (name.isEmpty) {
      state = '이름을 적어주세요';
      return const VisitorCheckStopped();
    }
    state = null;

    _isChecking = true;
    try {
      final userId = await ref
          .read(visitorRepositoryProvider)
          .findUserId(name)
          .timeout(_lookupLimit);
      return userId == null
          ? const VisitorNotFound()
          : VisitorFound(name: name, userId: userId);
    } catch (error) {
      if (isRetryableFailure(error)) {
        return VisitorCheckUnavailable(name: name);
      }
      if (ref.mounted) state = '확인하지 못했어요. 다시 눌러주세요';
      return const VisitorCheckStopped();
    } finally {
      _isChecking = false;
    }
  }
}
