import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_base_scaffold.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';
class SignupBasicPage extends StatelessWidget {
  const SignupBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BubdongBaseScaffold(
      showHomeButton: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SignupHeader(title: '법동에 온 걸 환영해!', currentStep: 1),
            const SizedBox(height: 37),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("반가워! 법동청소문화센터 다시 와줘서 고마워"),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
