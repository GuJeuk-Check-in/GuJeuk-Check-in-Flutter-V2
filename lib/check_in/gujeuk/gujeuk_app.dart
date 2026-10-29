import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/presentation/home_page.dart';

class GujeukApp extends StatefulWidget {
  /// 이 시간 동안 아무도 화면을 만지지 않으면 처음 화면으로 돌아갑니다.
  /// 공용 키오스크라 앞사람이 적던 개인정보가 다음 사람에게 보이지 않게 합니다.
  final Duration idleTimeout;

  const GujeukApp({super.key, this.idleTimeout = const Duration(minutes: 2)});

  @override
  State<GujeukApp> createState() => _GujeukAppState();
}

class _GujeukAppState extends State<GujeukApp> {
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
    // 처음 화면만 남아 있으면 그대로 둡니다.
    if (navigator == null || !navigator.canPop()) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구즉 체크인',
      theme: GujeukTheme.light,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      // 다이얼로그까지 Navigator 아래에 그려지므로 여기서 모든 터치를 받습니다.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _resetIdleTimer(),
        child: child,
      ),
      home: const HomePage(),
    );
  }
}
