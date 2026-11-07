import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/theme/gujeuk_theme.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/presentation/controller/outbox_sync_controller.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/presentation/home_page.dart';

class GujeukApp extends ConsumerStatefulWidget {
  /// 이 시간 동안 아무도 화면을 만지지 않으면 처음 화면으로 돌아갑니다.
  /// 공용 키오스크라 앞사람이 적던 개인정보가 다음 사람에게 보이지 않게 합니다.
  final Duration idleTimeout;

  const GujeukApp({super.key, this.idleTimeout = const Duration(minutes: 2)});

  @override
  ConsumerState<GujeukApp> createState() => _GujeukAppState();
}

class _GujeukAppState extends ConsumerState<GujeukApp> {
  /// 첫 화면에 크게 깔리는 이미지. 읽기 전에 첫 프레임을 그리면 이미지가 한 박자 늦게 나타납니다.
  static const _firstScreenImages = [
    AssetImage('assets/images/gujeuk/background.png'),
    AssetImage('assets/images/gujeuk/title.png'),
  ];

  final _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _idleTimer;
  bool _isPrecacheStarted = false;

  @override
  void initState() {
    super.initState();
    // 이미지를 다 읽을 때까지 스플래시를 띄워 두어, 첫 화면이 완성된 채로 나타나게 합니다.
    WidgetsBinding.instance.deferFirstFrame();
    _resetIdleTimer();
    // 어느 화면에 있든 쌓인 접수를 보낼 수 있게 앱과 함께 시작합니다.
    unawaited(ref.read(outboxSyncControllerProvider).start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isPrecacheStarted) return;
    _isPrecacheStarted = true;
    // precacheImage는 읽기에 실패해도 끝나므로 스플래시에 갇히지 않습니다.
    unawaited(
      Future.wait([
        for (final image in _firstScreenImages) precacheImage(image, context),
      ]).whenComplete(WidgetsBinding.instance.allowFirstFrame),
    );
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
