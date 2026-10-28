import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/number_range_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/gujeuk_signup_field.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/residence_dialog.dart';

class Middle extends StatelessWidget {
  final bool isSigned;
  final SignUpFormController form;

  const Middle({super.key, required this.form, this.isSigned = false});

  // 예약 API는 마감된 시간만 주므로 고를 수 있는 시간 전체는 앱에서 정합니다.
  static const _times = [
    '09:30',
    '10:30',
    '11:30',
    '12:30',
    '13:30',
    '14:30',
    '15:30',
    '16:30',
    '17:30',
  ];

  // 거주지 검색 API가 붙기 전까지 쓰는 임시 목록입니다.
  static const _residences = [
    '구즉동',
    '관평동',
    '신성동',
    '전민동',
    '노은1동',
    '노은2동',
    '노은3동',
    '온천1동',
    '온천2동',
    '원신흥동',
    '상대동',
    '학하동',
    '진잠동',
  ];

  Future<void> _pickResidence(BuildContext context) async {
    final residence = await ResidenceDialog.show(
      context,
      residences: _residences,
      selected: form.residence,
    );
    if (residence == null) return;
    form.selectResidence(residence);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Column(
        children: [
          GujeukLabeledField(
            label: '오늘은 무엇을 하러 왔어?',
            icon: GujeukIcons.rocket,
            errorText: form.purposeError,
            child: _purposeGrid(),
          ),
          if (form.needsTime) ...[
            const SizedBox(height: GujeukSpacing.s60),
            // 마감 시간을 받기 전에는 고를 수 없게 막아둡니다.
            GujeukTimeSlotPicker(
              times: _times,
              reservedTimes: form.reservedTimes ?? const {},
              selectedTime: form.time,
              onSelected: form.reservedTimes == null ? null : form.selectTime,
            ),
            if (form.reservedLoadError != null) ...[
              const SizedBox(height: GujeukSpacing.s16),
              _LoadError(
                message: form.reservedLoadError!,
                onRetry: form.loadReservedTimes,
              ),
            ],
            if (form.timeError != null) ...[
              const SizedBox(height: GujeukSpacing.s16),
              Align(
                alignment: Alignment.centerLeft,
                child: SignUpErrorText(form.timeError!),
              ),
            ],
          ],
          if (isSigned == false) ...[
          const SizedBox(height: GujeukSpacing.s60),
            GujeukLabeledField(
              label: '이름이 뭐야?',
              icon: GujeukIcons.user,
              child: GujeukInput(
                hintText: '친구의 이름을 알려줘',
                controller: form.nameController,
                errorText: form.nameError,
              ),
            ),
            const SizedBox(height: GujeukSpacing.s60),
            GujeukLabeledField(
              label: '전화번호가 뭐야?',
              icon: GujeukIcons.phone,
              child: GujeukInput(
                hintText: '전화번호를 입력해주세요',
                controller: form.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: const [PhoneNumberFormatter()],
                errorText: form.phoneError,
              ),
            ),
            const SizedBox(height: GujeukSpacing.s60),
            GujeukLabeledField(
              label: '성별이 뭐야?',
              icon: GujeukIcons.gender,
              errorText: form.genderError,
              child: Row(
                children: [
                  Expanded(child: _genderToggle(GujeukGender.male)),
                  const SizedBox(width: GujeukSpacing.s26),
                  Expanded(child: _genderToggle(GujeukGender.female)),
                ],
              ),
            ),
            const SizedBox(height: GujeukSpacing.s60),
            GujeukLabeledField(
              label: '언제 태어났어?',
              icon: GujeukIcons.cake,
              errorText: form.birthError,
              child: Row(
                children: [
                  Expanded(
                    child: _birthInput(
                      form.birthYearController,
                      '년도',
                      '2009',
                      NumberRangeFormatter(
                        min: 1900,
                        max: DateTime.now().year,
                        accepts: form.canBeBirthYear,
                      ),
                    ),
                  ),
                  const SizedBox(width: GujeukSpacing.s26),
                  Expanded(
                    child: _birthInput(
                      form.birthMonthController,
                      '월',
                      '3',
                      NumberRangeFormatter(
                        min: 1,
                        max: 12,
                        accepts: form.canBeBirthMonth,
                      ),
                    ),
                  ),
                  const SizedBox(width: GujeukSpacing.s26),
                  Expanded(
                    child: _birthInput(
                      form.birthDayController,
                      '일',
                      '5',
                      NumberRangeFormatter(
                        min: 1,
                        max: 31,
                        accepts: form.canBeBirthDay,
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
                onTap: () => _pickResidence(context),
                child: AbsorbPointer(
                  child: GujeukInput(
                    hintText: '너가 살고 있는 동네를 알려줘',
                    controller: form.residenceController,
                    showTrailingIcon: true,
                    errorText: form.residenceError,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: GujeukSpacing.s60),
          GujeukLabeledField(
            label: '친구들과 함께 왔니?',
            icon: GujeukIcons.friends,
            child: Row(
              children: [
                Expanded(
                  child: GujeukCompanionStepper(
                    gender: GujeukGender.male,
                    count: form.maleCount,
                    onChanged: form.setMaleCount,
                  ),
                ),
                const SizedBox(width: GujeukSpacing.s16),
                Expanded(
                  child: GujeukCompanionStepper(
                    gender: GujeukGender.female,
                    count: form.femaleCount,
                    onChanged: form.setFemaleCount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _purposeGrid() {
    final purposes = form.visitPurposes;
    if (purposes == null) {
      final error = form.purposesLoadError;
      if (error != null) {
        return _LoadError(message: error, onRetry: form.loadPurposes);
      }
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
              onTap: () => form.selectPurpose(purpose.purpose),
            );
          },
        );
      },
    );
  }

  Widget _genderToggle(GujeukGender gender) {
    return GujeukGenderToggle(
      gender: gender,
      selected: form.gender == gender,
      onTap: () => form.selectGender(gender),
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
