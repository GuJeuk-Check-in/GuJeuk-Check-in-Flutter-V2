import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/component/bubdong_component.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/domain/visit_route.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_card.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/presentation/widgets/signup_header.dart';

class SignupExtraSecondPage extends StatefulWidget {
  const SignupExtraSecondPage({super.key});

  @override
  State<SignupExtraSecondPage> createState() => _SignupExtraSecondPageState();
}

class _SignupExtraSecondPageState extends State<SignupExtraSecondPage> {
  VisitRoute? _visitRoute;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 줄: 학교 | 학교 검색 | 학년
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      flex: 4,
                      child: BubdongInput(
                        label: '학교가 뭐야?',
                        hintText: '친구의 학교를 알려줘',
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    BubdongButton(
                      label: '학교 검색',
                      onPressed: () {},
                      variant: BubdongButtonVariant.tone,
                      size: BubdongButtonSize.large,
                    ),
                    const SizedBox(width: 66),
                    Expanded(
                      flex: 1,
                      child: BubdongInput(
                        label: '학년이 뭐야?',
                        hintText: '3',
                        suffixText: '학년',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BubdongSpacing.s40),

                // 주소
                const BubdongInput(label: '어디에 살아?', hintText: '주소를 입력해줘'),
                const SizedBox(height: 54),

                // 방문 경로
                Text('문화 센터를 어떻게 알게 되었어?', style: BubdongTypography.fieldLabel),
                const SizedBox(height: BubdongSpacing.s24),
                Row(
                  children: [
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.friend.label,
                        icon: Icons.people_outline,
                        color: BubdongCardColor.orange,
                        selected: _visitRoute == VisitRoute.friend,
                        onTap: () => setState(() => _visitRoute = VisitRoute.friend),
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.parent.label,
                        icon: Icons.family_restroom,
                        color: BubdongCardColor.mint,
                        selected: _visitRoute == VisitRoute.parent,
                        onTap: () => setState(() => _visitRoute = VisitRoute.parent),
                      ),
                    ),
                    const SizedBox(width: BubdongSpacing.s20),
                    Expanded(
                      child: BubdongSelectCard(
                        label: VisitRoute.other.label,
                        icon: Icons.edit,
                        color: BubdongCardColor.blue,
                        selected: _visitRoute == VisitRoute.other,
                        onTap: () => setState(() => _visitRoute = VisitRoute.other),
                      ),
                    ),
                  ],
                ),

                // 기타를 골랐을 때만 보이는 입력칸
                if (_visitRoute == VisitRoute.other) ...[
                  const SizedBox(height: BubdongSpacing.s40),
                  const BubdongInput(
                    label: '기타 (어떻게 알게 됐어?)',
                    hintText: '기타',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: BubdongSpacing.s64),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BubdongButton(
                width: 320,
                label: '이전',
                onPressed: () => Navigator.of(context).pop(),
                variant: BubdongButtonVariant.tone,
              ),
              const SizedBox(width: BubdongSpacing.s40),
              BubdongButton(width: 320, label: '다음', onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}