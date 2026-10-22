import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/component/gujeuk_icon.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/theme/gujeuk_theme.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;

  /// 왼쪽 위에 뒤로가기 버튼을 띄웁니다. 시스템 뒤로가기가 막힌 키오스크에서도 돌아갈 수 있게 합니다.
  final bool showBackButton;

  const BaseScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: GujeukSpacing.s20),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gujeuk/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 화면보다 길어지면(세로 모드·키보드) 스크롤하고, 짧으면 가운데 정렬합니다.
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(child: child),
                  ),
                ),
              ),
              if (showBackButton)
                Positioned(
                  top: GujeukSpacing.s20,
                  left: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    // 아이콘(24)보다 넉넉한 터치 영역을 줍니다.
                    child: const SizedBox(
                      width: GujeukSpacing.s48,
                      height: GujeukSpacing.s48,
                      child: Center(child: GujeukIcon(GujeukIcons.arrowLeft)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
