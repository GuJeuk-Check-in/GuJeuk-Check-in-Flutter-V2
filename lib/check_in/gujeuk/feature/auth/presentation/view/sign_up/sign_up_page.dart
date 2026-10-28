import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/fake_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/bottom.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  /// 웹과 같은 카드 최대 너비. 1920 화면에서 좌우 448씩 여백이 생깁니다.
  /// 고정 여백 대신 최대 너비로 잡아 작은 화면에서도 깨지지 않게 합니다.
  static const double _cardMaxWidth = 1232;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 퍼블리싱용 가짜 응답입니다. 서버 연동 때 실제 구현으로 바꿉니다.
  final SignUpFormController _form = SignUpFormController(
    const FakeReservationRepository(),
  );

  @override
  void initState() {
    super.initState();
    _form.loadPurposes();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_form.validate()) return;
    // TODO 회원가입 요청

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationEndPage(
          reservation: _form.needsTime
              ? ReservationInfo(
                  name: _form.nameController.text.trim(),
                  purpose: _form.purpose!,
                  phone: _form.phoneController.text.trim(),
                  startTime: _form.time!,
                  maleCount: _form.maleCount,
                  femaleCount: _form.femaleCount,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s100),
        child: Container(
          constraints: const BoxConstraints(maxWidth: SignUpPage._cardMaxWidth),
          padding: EdgeInsets.all(GujeukSpacing.s64),
          decoration: BoxDecoration(
            border: Border.all(color: GujeukColors.borderCard, width: 4),
            boxShadow: GujeukShadows.card,
            color: GujeukColors.bgSurface,
            borderRadius: BorderRadius.circular(GujeukRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(title: '구즉 청소년문화의 집에 온걸 환영해~!'),
              const SizedBox(height: GujeukSpacing.s40),
              Middle(form: _form, isSigned: false),
              const SizedBox(height: GujeukSpacing.s100),
              Bottom(form: _form, onSubmit: _onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}
