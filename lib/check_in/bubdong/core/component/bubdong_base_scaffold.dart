import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';

class BubdongBaseScaffold extends StatelessWidget {
  const BubdongBaseScaffold({
    super.key,
    required this.child,
    this.showHomeButton = false,
    this.topRight,
  });

  final bool showHomeButton;

  /// 화면 오른쪽 위에 떠 있는 위젯 (자동 저장 토스트)
  final Widget? topRight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bubdong/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
              if (topRight != null)
                Positioned(
                  top: BubdongLayout.toastMargin,
                  right: BubdongLayout.toastMargin,
                  child: topRight!,
                ),
              if (showHomeButton)
                Positioned(
                  left: BubdongSpacing.s48,
                  bottom: BubdongSpacing.s32,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(BubdongSpacing.s8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chevron_left,
                            size: 16,
                            color: BubdongColors.textPlaceholder,
                          ),
                          Text(
                            '처음으로',
                            style: BubdongTypography.bodySm.copyWith(
                              color: BubdongColors.textPlaceholder,
                            ),
                          ),
                        ],
                      ),
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
