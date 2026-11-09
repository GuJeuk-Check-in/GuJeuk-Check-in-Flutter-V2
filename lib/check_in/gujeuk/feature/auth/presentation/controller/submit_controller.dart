import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';

/// 제출을 마친 뒤 화면이 할 일. 다이얼로그와 화면 이동은 화면이 맡습니다.
sealed class SubmitResult {
  const SubmitResult();
}

/// 완료 화면으로 갑니다. [reservation]이 null이면 예약 없이 바로 이용하는 완료 화면입니다.
class SubmitDone extends SubmitResult {
  final ReservationInfo? reservation;

  const SubmitDone(this.reservation);
}

/// 같은 이름의 회원이 있어 예약 문자를 받을 전화번호가 필요합니다.
class SubmitNeedsPhone extends SubmitResult {
  const SubmitNeedsPhone();
}

/// 화면에 머뭅니다. 알려줄 것이 없을 때(이미 보내는 중 등)입니다.
class SubmitStopped extends SubmitResult {
  const SubmitStopped();
}

/// 비었거나 잘못 적은 칸이 있어 보내지 않았습니다.
/// 칸 아래 에러 문구는 화면 위쪽이라 버튼 근처에서 안 보일 수 있어, 화면이 모달로 한 번 더 알려줍니다.
class SubmitInvalid extends SubmitResult {
  /// 화면 위에서 아래 순서의 에러 문구.
  final List<String> messages;

  const SubmitInvalid(this.messages);
}

/// 보냈지만 실패했습니다. 화면이 [message]를 모달로 띄웁니다.
class SubmitFailed extends SubmitResult {
  final String message;

  const SubmitFailed(this.message);
}

/// 회원가입·이용 예약 제출의 공통 흐름.
/// 보내는 동안은 로딩이고, 실패하면 [SubmitFailed]를 돌려줍니다.
abstract class SubmitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// 요청하는 동안 버튼을 다시 눌러도 무시합니다.
  bool get isSubmitting => state.isLoading;

  /// 폼 검사에 걸렸을 때 돌려줄 결과. 지금 떠 있는 칸 에러를 모두 담습니다.
  @protected
  SubmitInvalid invalid() =>
      SubmitInvalid(ref.read(signUpFormProvider).errorMessages);

  /// [request]를 보내는 동안 로딩으로 두고, 실패하면 [failureMessage]를 담아 돌려줍니다.
  @protected
  Future<SubmitResult> run(
    String failureMessage,
    Future<SubmitResult> Function() request,
  ) async {
    state = const AsyncLoading();
    try {
      final result = await request();
      if (ref.mounted) state = const AsyncData(null);
      return result;
    } on SlotTakenException {
      // 그사이 다른 친구가 고른 시간을 예약했으면 실패 문구 대신 시간 칸 에러로 알려줍니다.
      if (!ref.mounted) return const SubmitStopped();
      ref.read(signUpFormProvider.notifier).rejectTakenTime();
      state = const AsyncData(null);
      return invalid();
    } catch (_) {
      if (ref.mounted) state = const AsyncData(null);
      return SubmitFailed(failureMessage);
    }
  }
}
