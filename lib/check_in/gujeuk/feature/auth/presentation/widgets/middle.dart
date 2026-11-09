import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/number_range_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_options.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_text_fields.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/gujeuk_signup_field.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/residence_dialog.dart';

class Middle extends ConsumerWidget {
  /// 개인정보 칸의 컨트롤러. null이면 이미 가입한 친구라 개인정보 칸을 숨깁니다.
  final SignUpTextFields? fields;

  const Middle({super.key, this.fields});

  Future<void> _pickResidence(
    BuildContext context,
    WidgetRef ref,
    SignUpTextFields fields,
  ) async {
    final residences = ref.read(residencesProvider);
    final list = residences.value;
    // 목록을 아직 못 받았으면 모달 대신 다시 불러옵니다.
    if (list == null) {
      if (!residences.isLoading) ref.invalidate(residencesProvider);
      return;
    }
    final residence = await ResidenceDialog.show(
      context,
      residences: list,
      selected: ref.read(signUpFormProvider).residence,
    );
    // 모달이 떠 있는 사이 처음 화면으로 돌아갔다면 컨트롤러가 이미 dispose됐습니다.
    if (residence == null || !context.mounted) return;
    fields.residence.text = residence;
    ref.read(signUpFormProvider.notifier).selectResidence(residence);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpFormProvider);
    final controller = ref.read(signUpFormProvider.notifier);
    final catalog = ref.watch(purposeCatalogProvider);
    final purpose = form.purpose;
    final needsTime = controller.needsTime;
    final fields = this.fields;

    return Column(
      children: [
        GujeukLabeledField(
          label: '오늘은 무엇을 하러 왔어?',
          icon: GujeukIcons.rocket,
          errorText: form.errorOf(SignUpField.purpose),
          child: _purposeGrid(ref, catalog, form, controller),
        ),
        if (needsTime && purpose != null) ...[
          const SizedBox(height: GujeukSpacing.s60),
          ..._timePicker(ref, purpose, form, controller),
        ],
        if (fields != null) ...[
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '이름이 뭐야?',
            icon: GujeukIcons.user,
            child: GujeukInput(
              hintText: '친구의 이름을 알려줘',
              controller: fields.name,
              errorText: form.errorOf(SignUpField.name),
            ),
          ),
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '전화번호가 뭐야?',
            icon: GujeukIcons.phone,
            child: GujeukInput(
              hintText: '전화번호를 입력해주세요',
              controller: fields.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: const [PhoneNumberFormatter()],
              errorText: form.errorOf(SignUpField.phone),
            ),
          ),
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '성별이 뭐야?',
            icon: GujeukIcons.gender,
            errorText: form.errorOf(SignUpField.gender),
            child: Row(
              children: [
                Expanded(
                  child: _genderToggle(GujeukGender.male, form, controller),
                ),
                const SizedBox(width: GujeukSpacing.s26),
                Expanded(
                  child: _genderToggle(GujeukGender.female, form, controller),
                ),
              ],
            ),
          ),
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '언제 태어났어?',
            icon: GujeukIcons.cake,
            errorText: form.errorOf(SignUpField.birth),
            child: Row(
              children: [
                Expanded(
                  child: _birthInput(
                    fields.birthYear,
                    '년도',
                    // 힌트가 입력한 값처럼 보이지 않게 '예)'를 붙입니다.
                    '예) 2009',
                    NumberRangeFormatter(
                      min: 1900,
                      max: DateTime.now().year,
                      accepts: fields.canBeBirthYear,
                    ),
                  ),
                ),
                const SizedBox(width: GujeukSpacing.s26),
                Expanded(
                  child: _birthInput(
                    fields.birthMonth,
                    '월',
                    '예) 3',
                    NumberRangeFormatter(
                      min: 1,
                      max: 12,
                      accepts: fields.canBeBirthMonth,
                    ),
                  ),
                ),
                const SizedBox(width: GujeukSpacing.s26),
                Expanded(
                  child: _birthInput(
                    fields.birthDay,
                    '일',
                    '예) 5',
                    NumberRangeFormatter(
                      min: 1,
                      max: 31,
                      accepts: fields.canBeBirthDay,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '어디 살아?',
            icon: GujeukIcons.home,
            child: GestureDetector(
              onTap: () => _pickResidence(context, ref, fields),
              child: AbsorbPointer(
                child: GujeukInput(
                  hintText: '너가 살고 있는 동네를 알려줘',
                  controller: fields.residence,
                  showTrailingIcon: true,
                  errorText: _residenceError(ref, form),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: GujeukSpacing.s60),
        GujeukLabeledField(
          label: '친구들과 함께 왔니?',
          icon: GujeukIcons.friends,
          errorText: form.errorOf(SignUpField.companion),
          child: Row(
            children: [
              Expanded(
                child: GujeukCompanionStepper(
                  gender: GujeukGender.male,
                  count: form.maleCount,
                  // 남녀를 합쳐 정원을 넘지 않게, 한쪽 최대는 다른 쪽 수만큼 줄입니다.
                  max: _companionMax(catalog, purpose, form.femaleCount),
                  onChanged: controller.setMaleCount,
                ),
              ),
              const SizedBox(width: GujeukSpacing.s16),
              Expanded(
                child: GujeukCompanionStepper(
                  gender: GujeukGender.female,
                  count: form.femaleCount,
                  max: _companionMax(catalog, purpose, form.maleCount),
                  onChanged: controller.setFemaleCount,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _timePicker(
    WidgetRef ref,
    String purpose,
    SignUpFormState form,
    SignUpFormController controller,
  ) {
    final available = ref.watch(availableTimesProvider(purpose));
    final availableTimes = available.value;
    // 불러오지 못하면 어떤 칸이 찼는지 모르므로 모든 칸을 회색으로 막습니다.
    final failed = available.hasError && !available.isLoading;
    final timeError = form.errorOf(SignUpField.time);
    return [
      // 불러오는 동안은 칸을 흐리게 막고, 다시 불러올 때는 지난 마감 시간을 그대로 보여줍니다.
      GujeukTimeSlotPicker(
        times: SignUpFormController.times,
        reservedTimes: availableTimes == null
            ? const {}
            : SignUpFormController.times.toSet().difference(availableTimes),
        pastTimes: controller.pastTimes(),
        selectedTime: form.time,
        isLoading: available.isLoading,
        onSelected: failed ? null : controller.selectTime,
      ),
      if (failed) ...[
        const SizedBox(height: GujeukSpacing.s16),
        _LoadError(
          message: '예약 현황을 불러오지 못했어요',
          onRetry: () => ref.invalidate(availableTimesProvider(purpose)),
        ),
      ],
      if (timeError != null) ...[
        const SizedBox(height: GujeukSpacing.s16),
        Align(
          alignment: Alignment.centerLeft,
          child: SignUpErrorText(timeError),
        ),
      ],
    ];
  }

  /// 고르지 않았다는 에러가 먼저고, 없으면 목록을 못 불러온 문구를 띄웁니다.
  /// 칸을 다시 누르면 다시 불러옵니다.
  String? _residenceError(WidgetRef ref, SignUpFormState form) {
    final residences = ref.watch(residencesProvider);
    if (form.errorOf(SignUpField.residence) case final error?) return error;
    if (residences.hasError && !residences.isLoading) {
      return '동네 목록을 불러오지 못했어요. 다시 눌러주세요';
    }
    return null;
  }

  Widget _purposeGrid(
    WidgetRef ref,
    AsyncValue<PurposeCatalog> catalog,
    SignUpFormState form,
    SignUpFormController controller,
  ) {
    final loaded = catalog.value;
    if (loaded == null) {
      if (catalog.hasError && !catalog.isLoading) {
        return _LoadError(
          message: '방문 목적을 불러오지 못했어요. 계속 안 되면 직원에게 말해줘',
          onRetry: () => ref.invalidate(purposeCatalogProvider),
        );
      }
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final purposes = loaded.purposes;

    // Android는 창 크기를 받기 전 너비 0으로 첫 프레임을 그립니다.
    // 너비 0인 GridView는 assert로 렌더 트리를 깨뜨리므로 그릴 너비가 생길 때까지 비워둡니다.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // 카드 아래 3D 그림자가 잘리지 않게 합니다.
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 206,
            mainAxisExtent: 140,
            crossAxisSpacing: GujeukSpacing.s16,
            mainAxisSpacing: GujeukSpacing.s16,
          ),
          itemCount: purposes.length,
          itemBuilder: (context, index) {
            final purpose = purposes[index];
            return GujeukOptionCard(
              // `친친마루(게임, 독서 등)`을 이름과 설명 두 줄로 나눕니다.
              label: purpose.purpose.replaceFirst('(', '\n('),
              // 목적 개수가 API에 따라 달라지므로 색은 순서대로 돌려 씁니다.
              accent: GujeukOptionAccent
                  .values[index % GujeukOptionAccent.values.length],
              selected: form.purpose == purpose.purpose,
              onTap: () => controller.selectPurpose(purpose.purpose),
            );
          },
        );
      },
    );
  }

  int? _companionMax(
    AsyncValue<PurposeCatalog> catalog,
    String? purpose,
    int otherCount,
  ) {
    final max = catalog.value?.maxCompanions(purpose);
    return max == null ? null : max - otherCount;
  }

  Widget _genderToggle(
    GujeukGender gender,
    SignUpFormState form,
    SignUpFormController controller,
  ) {
    return GujeukGenderToggle(
      gender: gender,
      selected: form.gender == gender,
      onTap: () => controller.selectGender(gender),
    );
  }

  Widget _birthInput(
    TextEditingController controller,
    String label,
    String hintText,
    NumberRangeFormatter range,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GujeukTypography.bodyMd),
        const SizedBox(height: GujeukSpacing.s10),
        GujeukInput(
          hintText: hintText,
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: range.maxDigits,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, range],
        ),
      ],
    );
  }
}

/// 조회 실패 문구와 다시 시도 버튼.
class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SignUpErrorText(message),
        GujeukButton(
          label: '다시 시도',
          variant: GujeukButtonVariant.neutralMedium,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
