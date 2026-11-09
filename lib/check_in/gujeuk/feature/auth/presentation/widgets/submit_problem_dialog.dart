import 'package:flutter/widgets.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/submit_controller.dart';

/// 제출이 막힌 이유를 모달로 알려줍니다.
/// 칸 아래 에러 문구는 화면 위쪽에 있어 버튼을 누른 자리에서 안 보일 수 있기 때문입니다.
/// [result]가 [SubmitInvalid]·[SubmitFailed]가 아니면 아무것도 띄우지 않습니다.
Future<void> showSubmitProblem(BuildContext context, SubmitResult result) {
  switch (result) {
    case SubmitInvalid(:final messages) when messages.isNotEmpty:
      return GujeukDialog.alert(
        context,
        title: '아직 확인할 게 있어!',
        description: messages.join('\n'),
      );
    case SubmitFailed(:final message):
      return GujeukDialog.alert(
        context,
        title: '앗, 문제가 생겼어',
        description: message,
      );
    default:
      return Future.value();
  }
}
