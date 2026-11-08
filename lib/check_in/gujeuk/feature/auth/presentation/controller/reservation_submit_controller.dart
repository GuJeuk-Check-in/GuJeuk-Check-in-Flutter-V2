import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/check_in_submitter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/repository_providers.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/submit_controller.dart';

final reservationSubmitProvider =
    AsyncNotifierProvider.autoDispose<ReservationSubmitController, void>(
      ReservationSubmitController.new,
    );

/// 다시 온 친구의 이용 제출.
class ReservationSubmitController extends SubmitController {
  /// 목적·시간·인원을 검사하고 보냅니다.
  /// 예약이 필요 없는 목적은 방문 기록만 남기고, 예약이 필요하면 처음엔 전화번호 없이 예약합니다.
  Future<SubmitResult> submit({
    required String name,
    required int userId,
  }) async {
    if (isSubmitting) return const SubmitStopped();
    final formController = ref.read(signUpFormProvider.notifier);
    if (!formController.validateReservation()) return invalid();

    if (formController.needsTime) return _reserve(name: name);
    final form = ref.read(signUpFormProvider);
    return run('기록하지 못했어요. 다시 눌러주세요', () async {
      await ref
          .read(checkInSubmitterProvider)
          .submitCheckIn(
            userId: userId,
            purpose: form.purpose!,
            maleCount: form.maleCount,
            femaleCount: form.femaleCount,
          );
      return const SubmitDone(null);
    });
  }

  /// [SubmitNeedsPhone] 뒤에, 예약 문자를 받을 번호를 실어 같은 내용으로 한 번 더 보냅니다.
  Future<SubmitResult> retryWithPhone({
    required String name,
    required String phone,
  }) async {
    if (isSubmitting) return const SubmitStopped();
    // 번호를 적는 사이 고른 시간이 지났을 수 있어 다시 검사합니다.
    final formController = ref.read(signUpFormProvider.notifier);
    if (!formController.validateReservation()) return invalid();
    return _reserve(name: name, phone: phone);
  }

  /// 같은 이름의 회원이 있다는 409가 오면 [SubmitNeedsPhone]을 돌려줍니다.
  Future<SubmitResult> _reserve({required String name, String? phone}) {
    final form = ref.read(signUpFormProvider);
    return run('예약하지 못했어요. 다시 눌러주세요', () async {
      try {
        await ref
            .read(reservationRepositoryProvider)
            .reserve(
              name: name,
              phone: phone == null
                  ? null
                  : PhoneNumberFormatter.digitsOf(phone),
              purpose: form.purpose!,
              startTime: form.time!,
              maleCount: form.maleCount,
              femaleCount: form.femaleCount,
            );
      } on DuplicateNameException {
        return const SubmitNeedsPhone();
      }
      return SubmitDone(
        ReservationInfo(
          name: name,
          purpose: form.purpose!,
          phone: phone ?? '',
          startTime: form.time!,
          maleCount: form.maleCount,
          femaleCount: form.femaleCount,
        ),
      );
    });
  }
}
