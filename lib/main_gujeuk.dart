import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/server_clock.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/gujeuk_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1920×1080 가로 키오스크 전용이라 기기 자동 회전이 켜져 있어도 가로로 둡니다.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // 상태바와 내비게이션 바를 숨깁니다. 가장자리를 쓸어 잠깐 꺼내도 다시 숨습니다.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await dotenv.load(fileName: '.env.gujeuk');
  ensureBaseUrl();
  final container = ProviderContainer();
  // 첫 접수부터 보정한 시각을 쓰도록 화면을 띄우기 전에 읽습니다.
  await container.read(serverClockProvider).load();
  runApp(
    UncontrolledProviderScope(container: container, child: const GujeukApp()),
  );
}
