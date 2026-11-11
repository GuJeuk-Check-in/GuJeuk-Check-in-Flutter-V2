import 'package:flutter/material.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/bubdong_app.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/bubdong/core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.bubdong');
  ensureBaseUrl();
  runApp(const BubdongApp());
}
