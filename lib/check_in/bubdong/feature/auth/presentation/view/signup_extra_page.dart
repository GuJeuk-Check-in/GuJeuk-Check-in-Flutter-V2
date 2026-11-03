import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_card.dart';

class SignupExtraPage extends StatefulWidget {
  const SignupExtraPage({super.key});

  @override
  State<SignupExtraPage> createState() => _SignupExtraPageState();
}

class _SignupExtraPageState extends State<SignupExtraPage> {
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SignupHeader(title: '처음 방문하셨나요?', currentStep: 2),
          const SizedBox(height: BubdongSpacing.s40),
          SignupCard(
            width: 1080,
            padding: const EdgeInsets.fromLTRB(60, 40, 60, 180),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 첫 줄: 이름 | 생년월일
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 460,
                      child: BubdongInput(
                        label: '이름이 뭐야?',
                        hintText: '친구의 이름을 알려줘',
                      ),
                    ),
                    SizedBox(
                      width: 460,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '생년월일이 뭐야?',
                            style: BubdongTypography.subtitle.copyWith(
                              color: BubdongColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: BubdongSpacing.s4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 170,
                                child: BubdongDropdown(
                                  hintText: '연도',
                                  items: List.generate(100, (i) => '${2026 - i}'),
                                  onChanged: (value) {},
                                ),
                              ),
                              SizedBox(
                                width: 125,
                                child: BubdongDropdown(
                                  hintText: '월',
                                  items: List.generate(12, (i) => '${i + 1}'),
                                  onChanged: (value) {},
                                ),
                              ),
                              SizedBox(
                                width: 125,
                                child: BubdongDropdown(
                                  hintText: '일',
                                  items: List.generate(31, (i) => '${i + 1}'),
                                  onChanged: (value) {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 둘째 줄: 성별 | 전화번호
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 460,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '성별',
                            style: BubdongTypography.subtitle.copyWith(
                              color: BubdongColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: BubdongSpacing.s4),
                          Row(
                            children: [
                              SizedBox(
                                width: 180,
                                child: BubdongSelectCard(
                                  label: '남자',
                                  icon: Icons.male,
                                  color: BubdongCardColor.mint,
                                  selected: _gender == '남자',
                                  onTap: () => setState(() => _gender = '남자'),
                                ),
                              ),
                              const SizedBox(width: BubdongSpacing.s20),
                              SizedBox(
                                width: 180,
                                child: BubdongSelectCard(
                                  label: '여자',
                                  icon: Icons.female,
                                  color: BubdongCardColor.pink,
                                  selected: _gender == '여자',
                                  onTap: () => setState(() => _gender = '여자'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 460,
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
          const SizedBox(height: 64),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 320,
                child: BubdongButton(
                  label: '이전',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: BubdongButtonVariant.tone,
                ),
              ),
              const SizedBox(width: 40),
              SizedBox(
                width: 320,
                child: BubdongButton(label: '다음', onPressed: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}