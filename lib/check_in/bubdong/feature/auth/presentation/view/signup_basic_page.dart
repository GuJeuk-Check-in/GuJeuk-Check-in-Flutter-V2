import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/auth/data/remote_user_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/domain/visitor_type.dart';

import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/facility/presentation/view/facility_select_page.dart';
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
  final _repository = RemoteUserRepository(bubdongApiClient);
  bool _isLoading = false;
  String? _error;

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

  //전화번호로 회원인지 확인하고 다음 화면으로
  Future<void> _next() async {
    final phone = _phoneController.text.trim();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userId = await _repository.findUserId(phone);
      if (!mounted) return;
      if (userId != null) {
        //다시 온친구 -> 이용대장 선택화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const FacilitySelectPage(visitorType: VisitorType.child),
          ),
        );
      } else {
        //처음 온 친구 -> 회원가입 화면으로 이동
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SignupExtraPage()));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '확인하지 못했어요. 잠시 후 다시 시도해주세요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                if (_error != null) ...[
                  const SizedBox(height: BubdongSpacing.s12),
                  Text(
                    _error!,
                    style: BubdongTypography.bodySm.copyWith(
                      color: BubdongColors.borderError,
                    ),
                  ),
                ],
                const SizedBox(height: BubdongLayout.signupBasicButtonGap),
                BubdongButton(
                  label: "다음으로 넘어가기 →",
                  variant: BubdongButtonVariant.primaryLarge,
                  isLoading: _isLoading,
                  onPressed: _phoneController.text.trim().isEmpty
                      ? null //전화번를 적어야 누를수 있음
                      : _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
