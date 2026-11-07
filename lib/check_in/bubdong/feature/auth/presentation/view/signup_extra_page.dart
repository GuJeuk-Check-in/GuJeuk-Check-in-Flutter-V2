import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/gender.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_extra_second_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';

class SignupExtraPage extends StatefulWidget {
  const SignupExtraPage({super.key});

  @override
  State<SignupExtraPage> createState() => _SignupExtraPageState();
}

class _SignupExtraPageState extends State<SignupExtraPage> {
  Gender? _gender;
  String? _year;
  String? _month;
  String? _day;

  /// 고른 연도·월의 마지막 날 (안 골랐으면 31)
  int get _daysInMonth {
    final year = int.tryParse(_year ?? '');
    final month = int.tryParse(_month ?? '');
    if (year == null || month == null) return 31;
    return DateTime(year, month + 1, 0).day; // 다음 달 0일 = 이번 달 마지막 날
  }

  /// 연도·월을 바꿨을 때, 고른 일이 그 달에 없으면 지우기
  void _clearDayIfInvalid() {
    final day = int.tryParse(_day ?? '');
    if (day != null && day > _daysInMonth) _day = null;
  }

  @override
  Widget build(BuildContext context) {
    final thisYear = DateTime.now().year;

    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SignupHeader(title: '처음 방문하셨나요?', currentStep: 2),
          const SizedBox(height: BubdongSpacing.s40),
          BubdongContentCard(
            width: BubdongLayout.formCardWidth,
            padding: BubdongLayout.signupCardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 첫 줄: 이름 | 생년월일
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: BubdongInput(
                        label: '이름이 뭐야?',
                        hintText: '친구의 이름을 알려줘',
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s40),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('생년월일이 뭐야?', style: BubdongTypography.fieldLabel),
                          const SizedBox(height: BubdongSpacing.s4),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: BubdongDropdown(
                                  hintText: '연도',
                                  items: List.generate(100, (i) => '${thisYear - i}'),
                                  value: _year,
                                  onChanged: (value) => setState(() {
                                    _year = value;
                                    _clearDayIfInvalid();
                                  }),
                                ),
                              ),
                              const SizedBox(width: BubdongSpacing.s20),
                              Expanded(
                                flex: 3,
                                child: BubdongDropdown(
                                  hintText: '월',
                                  items: List.generate(12, (i) => '${i + 1}'),
                                  value: _month,
                                  onChanged: (value) => setState(() {
                                    _month = value;
                                    _clearDayIfInvalid();
                                  }),
                                ),
                              ),
                              const SizedBox(width: BubdongSpacing.s20),
                              Expanded(
                                flex: 3,
                                child: BubdongDropdown(
                                  hintText: '일',
                                  items: List.generate(_daysInMonth, (i) => '${i + 1}'),
                                  value: _day,
                                  onChanged: (value) => setState(() => _day = value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: BubdongSpacing.s40),

                // 둘째 줄: 성별 | 전화번호
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('성별', style: BubdongTypography.fieldLabel),
                          const SizedBox(height: BubdongSpacing.s4),
                          Row(
                            children: [
                              Expanded(
                                child: BubdongSelectCard(
                                  label: Gender.male.label,
                                  icon: Icons.male,
                                  color: BubdongCardColor.mint,
                                  selected: _gender == Gender.male,
                                  onTap: () => setState(() => _gender = Gender.male),
                                ),
                              ),
                              const SizedBox(width: BubdongSpacing.s20),
                              Expanded(
                                child: BubdongSelectCard(
                                  label: Gender.female.label,
                                  icon: Icons.female,
                                  color: BubdongCardColor.pink,
                                  selected: _gender == Gender.female,
                                  onTap: () => setState(() => _gender = Gender.female),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s40),
                    const Expanded(
                      child: BubdongInput(
                        label: '전화번호',
                        hintText: '친구의 전화번호를 알려줘',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s64),
          BubdongActionRow(
            onPrevious: () => Navigator.of(context).pop(),
            onNext: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignupExtraSecondPage()),
            ),
          ),
        ],
      ),
    );
  }
}