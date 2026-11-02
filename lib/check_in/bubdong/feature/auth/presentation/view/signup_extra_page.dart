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
            padding: EdgeInsets.fromLTRB(60, 40, 60, 180),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: BubdongInput(
                    label: '이름이 뭐야?',
                    hintText: '친구의 이름을 알려줘',
                  ),
                ),
                SizedBox(
                  width: ,
                  child: Column(
                    children: [
                    BubdongDropdown(
                      label: '생년월일이 뭐야?',
                      hintText: '연도',
                      items: List.generate(100, (i) => '${2026 - i}'),
                      onChanged: (value) {},
                    ),
                  ],
                  ),
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
