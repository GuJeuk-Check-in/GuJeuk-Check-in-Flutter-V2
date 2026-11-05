import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/server_clock.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/check_in_submitter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/submit_controller.dart';

final signUpSubmitProvider =
    AsyncNotifierProvider.autoDispose<SignUpSubmitController, void>(
      SignUpSubmitController.new,
    );

/// 처음 온 친구의 회원가입 제출.
class SignUpSubmitController extends SubmitController {
  /// 전체를 검사하고 가입합니다.
  /// 예약이 필요한 시설이면 가입 요청에 시간을 실어 한 번에 예약합니다.
  /// 예약 없는 가입은 서버 연결 문제일 때만 기기에 저장하고, [offline]이면 서버 대신 저장만 합니다.
  Future<SubmitResult> submit(SignUpTexts texts, {bool offline = false}) async {
    if (isSubmitting) return const SubmitStopped();
    final formController = ref.read(signUpFormProvider.notifier);
    if (!formController.validate(texts)) return const SubmitStopped();

    final form = ref.read(signUpFormProvider);
    final time = formController.needsTime ? form.time : null;
    final name = texts.name.trim();
    return run('가입하지 못했어요. 다시 눌러주세요', () async {
      final gender = switch (form.gender!) {
        GujeukGender.male => Gender.man,
        GujeukGender.female => Gender.woman,
      };
      final phone = PhoneNumberFormatter.digitsOf(texts.phone);
      final birthDate = SignUpFormController.birthDateOf(texts);
      if (time != null) {
        await ref
            .read(signUpRepositoryProvider)
            .signUp(
              name: name,
              gender: gender,
              phone: phone,
              birthDate: birthDate,
              residence: form.residence!,
              purpose: form.purpose!,
              maleCount: form.maleCount,
              femaleCount: form.femaleCount,
              visitTime: ref.read(serverClockProvider).now(),
              reservationTime: time,
            );
      } else if (offline) {
        await ref
            .read(checkInSubmitterProvider)
            .queueUnknownVisitor(
              name: name,
              gender: gender,
              phone: phone,
              birthDate: birthDate,
              residence: form.residence!,
              purpose: form.purpose!,
              maleCount: form.maleCount,
              femaleCount: form.femaleCount,
            );
      } else {
        await ref
            .read(checkInSubmitterProvider)
            .submitSignUp(
              name: name,
              gender: gender,
              phone: phone,
              birthDate: birthDate,
              residence: form.residence!,
              purpose: form.purpose!,
              maleCount: form.maleCount,
              femaleCount: form.femaleCount,
            );
      }
      return SubmitDone(
        time == null
            ? null
            : ReservationInfo(
                name: name,
                purpose: form.purpose!,
                phone: texts.phone.trim(),
                startTime: time,
                maleCount: form.maleCount,
                femaleCount: form.femaleCount,
              ),
      );
    });
  }
}
