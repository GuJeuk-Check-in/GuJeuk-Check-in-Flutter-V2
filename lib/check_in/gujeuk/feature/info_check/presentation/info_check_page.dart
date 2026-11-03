import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/reservation/reservation_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/sign_up/sign_up_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/presentation/controller/info_check_controller.dart';

class InfoCheckPage extends ConsumerStatefulWidget {
  const InfoCheckPage({super.key});

  @override
  ConsumerState<InfoCheckPage> createState() => _InfoCheckPageState();
}

class _InfoCheckPageState extends ConsumerState<InfoCheckPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final result = await ref
        .read(infoCheckProvider.notifier)
        .check(_nameController.text);
    if (!mounted) return;

    // 재방문이면 예약, 처음이면 회원가입으로 갑니다.
    final Widget next;
    switch (result) {
      case VisitorCheckStopped():
        return;
      case VisitorFound(:final name, :final userId):
        next = ReservationPage(name: name, userId: userId);
      case VisitorCheckUnavailable(:final name):
        next = SignUpPage(offline: true, initialName: name);
      case VisitorNotFound():
        // 이름을 잘못 적은 건 아닌지 한 번 묻고, 아니요면 이름을 다시 적게 둡니다.
        final isFirstVisit = await GujeukDialog.show(
          context,
          title: '시설에 혹시 처음 방문했니?',
          description: '정보를 잘못 입력했다면 아니요를 눌러서 이름을 다시 입력 할 수 있어',
        );
        if (!mounted || isFirstVisit != true) return;
        next = const SignUpPage();
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => next));
    // 돌아오면 다음 친구가 쓸 수 있게 이름 칸을 비웁니다.
    if (mounted) _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nameError = ref.watch(infoCheckProvider);
    final isNarrow = MediaQuery.sizeOf(context).width < 800;
    return BaseScaffold(
      showBackButton: true,
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
                  onChanged: (_) =>
                      ref.read(infoCheckProvider.notifier).clearError(),
                  errorText: nameError,
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
