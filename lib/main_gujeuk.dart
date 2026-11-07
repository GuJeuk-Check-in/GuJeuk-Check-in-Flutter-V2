import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/server_clock.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/gujeuk_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.gujeuk');
  ensureBaseUrl();
  final container = ProviderContainer();
  // 첫 접수부터 보정한 시각을 쓰도록 화면을 띄우기 전에 읽습니다.
  await container.read(serverClockProvider).load();
  runApp(
    UncontrolledProviderScope(container: container, child: const GujeukApp()),
  );
}
