import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/component/gujeuk_components.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/outbox_sync_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/view/sign_up/sign_up_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/presentation/info_check_page.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  /// 페이지 이동 중에 버튼을 다시 눌러도 같은 페이지가 쌓이지 않게 합니다.
  bool _isNavigating = false;

  Future<void> _onStart() async {
    if (_isNavigating) return;
    _isNavigating = true;
    // 서버가 내려가 있는 걸 이미 알면 이름 확인을 기다리지 않고 바로 폼으로 갑니다.
    final isServerDown = ref.read(outboxSyncControllerProvider).isServerDown;
    // push는 해당 페이지가 닫힐 때 끝나므로, 돌아온 뒤에 다시 누를 수 있습니다.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isServerDown
            ? const SignUpPage(name: '', offline: true)
            : const InfoCheckPage(),
      ),
    );
    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    // 첫 화면에서 시스템 뒤로가기를 누르면 앱이 꺼지므로 막습니다.
    return PopScope(
      canPop: false,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return BaseScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/gujeuk/title.png'),
          Text(
            '시설을 이용하려면 아래 버튼을 눌러줘',
            textAlign: TextAlign.center,
            style: GujeukTypography.headingLg.copyWith(
              color: GujeukColors.textAccent,
              shadows: GujeukShadows.glowText,
            ),
          ),
          const SizedBox(height: GujeukSpacing.s60),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: GujeukSpacing.s28,
            runSpacing: GujeukSpacing.s28,
            children: [
              GujeukButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: GujeukSpacing.s48,
                ),
                label: '시설 이용하기',
                variant: GujeukButtonVariant.landing,
                onPressed: _onStart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
