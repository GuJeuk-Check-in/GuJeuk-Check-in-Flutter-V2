import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/base_scaffold.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/done_box.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_button.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/color.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/radius.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/shadow.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/spacing.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/fake_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/sign_up_form_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_end_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/header.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/widgets/middle.dart';

class ReservationPage extends StatefulWidget {
  final String name;

  const ReservationPage({super.key, required this.name});

  static const double _cardMaxWidth = 1232;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
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

  void _onSubmit() {
    if (!_form.validateReservation()) return;
    // TODO 이용 예약 요청

    // 예약이 필요한 시설을 골랐을 때만 예약 정보를 넘깁니다.
    final reservation = _form.needsTime
        ? ReservationInfo(
            name: widget.name,
            purpose: _form.purpose!,
            phone: '',
            startTime: _form.time!,
            maleCount: _form.maleCount,
            femaleCount: _form.femaleCount,
          )
        : null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationEndPage(reservation: reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s100),
        child: Container(
          constraints: BoxConstraints(maxWidth: ReservationPage._cardMaxWidth),
          padding: EdgeInsets.all(GujeukSpacing.s64),
          decoration: BoxDecoration(
            border: Border.all(color: GujeukColors.borderCard, width: 4),
            boxShadow: GujeukShadows.card,
            color: GujeukColors.bgSurface,
            borderRadius: BorderRadius.circular(GujeukRadius.xl),
          ),
          child: Column(
            children: [
              Header(title: '반가워! 청소년문화의집에 다시 와줘서 고마워'),
              const SizedBox(height: GujeukSpacing.s40),
              Middle(form: _form, isSigned: true),
              const SizedBox(height: GujeukSpacing.s100),
              Row(
                children: [
                  Expanded(
                    child: GujeukButton(
                      label: '다 했어요!',
                      icon: GujeukIcons.party,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
