import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/theme/bubdong_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/feature/home/presentation/view/home_page.dart';

class BubdongApp extends StatefulWidget {
  /// 이 시간 동안 아무도 화면을 만지지 않으면 처음 화면으로 (구즉과 같은 2분)
  /// 공용 키오스크라 앞사람이 적던 개인정보가 다음 사람에게 보이지 않게 함
  final Duration idleTimeout;

  const BubdongApp({super.key, this.idleTimeout = const Duration(minutes: 2)});

  @override
  State<BubdongApp> createState() => _BubdongAppState();
}

class _BubdongAppState extends State<BubdongApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.idleTimeout, _goHome);
  }

  void _goHome() {
    final navigator = _navigatorKey.currentState;
    // 처음 화면만 남아 있으면 그대로 둠
    if (navigator == null || !navigator.canPop()) return;
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '법동 체크인',
      debugShowCheckedModeBanner: false,
      theme: BubdongTheme.light,
      navigatorKey: _navigatorKey,
      // 팝업까지 Navigator 아래에 그려지므로 여기서 모든 터치를 받음
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _resetIdleTimer(),
        child: child,
      ),
      home: const HomePage(),
    );
  }
}
