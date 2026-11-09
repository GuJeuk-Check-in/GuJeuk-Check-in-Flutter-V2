import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/view/signup_extra_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class SignupBasicPage extends StatefulWidget {
  const SignupBasicPage({super.key});

  @override
  State<SignupBasicPage> createState() => _SignupBasicPageState();
}

class _SignupBasicPageState extends State<SignupBasicPage> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {})); // 입력할 때마다 버튼 상태 갱신
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SignupHeader(title: '법동에 온 걸 환영해!', currentStep: 1),
          const SizedBox(height: BubdongLayout.signupBasicHeaderGap),
          BubdongContentCard(
            width: BubdongLayout.signupBasicCardWidth,
            padding: const EdgeInsets.all(BubdongSpacing.s64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "반가워! 법동청소년문화센터에 다시 와줘서 고마워",
                  style: BubdongTypography.titleLg.copyWith(
                    color: BubdongColors.textAccent,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s12),
                Text(
                  "시설을 이용하려면 작성해줘",
                  style: BubdongTypography.headingMd.copyWith(
                    color: BubdongColors.textAccent,
                  ),
                ),
                const SizedBox(height: BubdongSpacing.s40),
                BubdongInput(
                  label: "전화번호가 뭐야?",
                  hintText: "친구의 전화번호를 알려줘",
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _phoneController,
                ),
                const SizedBox(height: BubdongLayout.signupBasicButtonGap),
                BubdongButton(
                  label: "다음으로 넘어가기 →",
                  variant: BubdongButtonVariant.primaryLarge,
                  // TODO: API 연결 시 전화번호로 다시 온 친구인지 확인해서, 다시 왔으면 이용대장 선택으로 바로 이동
                  onPressed: _phoneController.text.trim().isEmpty
                      ? null // 전화번호를 적어야 누를 수 있음
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupExtraPage(),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
