import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/sign_up/sign_up_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/data/fake_visitor_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/domain/visitor_repository.dart';

class InfoCheckPage extends StatefulWidget {
  const InfoCheckPage({super.key});

  @override
  State<InfoCheckPage> createState() => _InfoCheckPageState();
}

class _InfoCheckPageState extends State<InfoCheckPage> {
  // 퍼블리싱용 가짜 응답입니다. 서버 연동 때 실제 구현으로 바꿉니다.
  final VisitorRepository _visitors = const FakeVisitorRepository();

  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  /// 조회하거나 다이얼로그가 떠 있는 동안 버튼을 다시 눌러도 무시합니다.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String _) {
    if (_nameError != null) setState(() => _nameError = null);
  }

  Future<void> _onNext() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final error = name.isEmpty ? '이름을 적어주세요' : null;
    setState(() => _nameError = error);
    if (error != null) return;

    _isSubmitting = true;
    try {
      final bool isReturning;
      try {
        isReturning = await _visitors.exists(name);
      } catch (_) {
        if (mounted) setState(() => _nameError = '확인하지 못했어요. 다시 눌러주세요');
        return;
      }
      if (!mounted) return;
      // 처음이면 이름을 잘못 적은 건 아닌지 한 번 묻고, 아니요면 이름을 다시 적게 둡니다.
      if (!isReturning) {
        final isFirstVisit = await GujeukDialog.show(
          context,
          title: '시설에 혹시 처음 방문했니?',
          description: '정보를 잘못 입력했다면 아니요를 눌러서 이름을 다시 입력 할 수 있어',
        );
        if (!mounted || isFirstVisit != true) return;
      }
      // 재방문이면 예약, 처음이면 회원가입으로 갑니다.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              isReturning ? ReservationPage(name: name) : const SignUpPage(),
        ),
      );
      if (mounted) {
        setState(() {
          _nameController.clear();
          _nameError = null;
        });
      }
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 800;
    return BaseScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GujeukSpacing.s20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(
              isNarrow ? GujeukSpacing.s32 : GujeukSpacing.s64,
            ),
            decoration: BoxDecoration(
              color: GujeukColors.bgSurface,
              boxShadow: GujeukShadows.card,
              borderRadius: BorderRadius.circular(GujeukRadius.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '반가워! 청소년문화의집에 다시 와줘서 고마워',
                  textAlign: TextAlign.center,
                  style: GujeukTypography.titleLg.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s12),
                Text(
                  '시설을 이용하려면 작성해줘',
                  textAlign: TextAlign.center,
                  style: GujeukTypography.headingMd.copyWith(
                    color: GujeukColors.textBrand,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: GujeukFieldLabel(
                    label: '이름이 뭐야?',
                    icon: GujeukIcons.user,
                  ),
                ),
                const SizedBox(height: GujeukSpacing.s10),
                GujeukInput(
                  hintText: '친구의 이름을 알려줘',
                  controller: _nameController,
                  onChanged: _onNameChanged,
                  errorText: _nameError,
                  maxLength: 30,
                ),
                const SizedBox(height: GujeukSpacing.s40),
                GujeukButton(
                  onPressed: _onNext,
                  label: '넘어가기!  -->',
                  variant: GujeukButtonVariant.primaryLarge,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
