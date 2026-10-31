import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `.env`의 `API_BASE_URL`. 없으면 에뮬레이터에서 PC의 8080 포트로 붙습니다.
String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

/// 서버 주소와 타임아웃이 설정된 Dio. 실제 요청은 각 repository가 보냅니다.
class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  static const Duration _timeout = Duration(seconds: 10);

  factory ApiClient.create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        contentType: Headers.jsonContentType,
      ),
    );
    // 디버그 빌드에서만 요청과 응답을 콘솔에 찍습니다.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return ApiClient(dio);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(baseUrl: baseUrl);
});
