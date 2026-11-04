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

/// 화면에 머뭅니다. 입력 에러나 실패 문구는 이미 화면에 떠 있습니다.
class SubmitStopped extends SubmitResult {
  const SubmitStopped();
}

/// 제출 요청이 실패했을 때 버튼 위에 띄울 문구. 제출 상태의 에러로 담깁니다.
class SubmitFailure implements Exception {
  final String message;

  const SubmitFailure(this.message);
}

extension SubmitStateMessage on AsyncValue<void> {
  /// 버튼 위에 띄울 실패 문구. 다시 보내는 동안에는 지난 문구를 숨깁니다.
  String? get submitError {
    if (isLoading) return null;
    return switch (error) {
      SubmitFailure(:final message) => message,
      _ => null,
    };
  }
}

/// 회원가입·이용 예약 제출의 공통 흐름.
/// 보내는 동안은 로딩이고, 실패하면 [SubmitFailure]가 에러로 담깁니다.
abstract class SubmitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// 요청하는 동안 버튼을 다시 눌러도 무시합니다.
  bool get isSubmitting => state.isLoading;

  /// [request]를 보내는 동안 로딩으로 두고, 실패하면 [failureMessage]를 띄웁니다.
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
      // 그사이 다른 친구가 고른 시간을 예약했으면 실패 문구 대신 시간 칸에 알려줍니다.
      if (!ref.mounted) return const SubmitStopped();
      ref.read(signUpFormProvider.notifier).rejectTakenTime();
      state = const AsyncData(null);
      return const SubmitStopped();
    } catch (_, stackTrace) {
      if (ref.mounted) {
        state = AsyncError(SubmitFailure(failureMessage), stackTrace);
      }
      return const SubmitStopped();
    }
  }
}
