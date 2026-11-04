import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `.env`의 `API_BASE_URL`. 없으면 잘못된 주소로 요청하지 않도록 에러를 던집니다.
String get baseUrl {
  final url = dotenv.maybeGet('API_BASE_URL');
  if (url == null || url.isEmpty) {
    throw StateError('.env.gujeuk에 API_BASE_URL이 없습니다');
  }
  return url;
}

/// 앱 시작 때 부릅니다. 주소가 없으면 첫 요청을 보내기 전에 바로 실패합니다.
void ensureBaseUrl() => baseUrl;

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
    // 요청 본문에는 이름, 전화번호, 생년월일이 들어 있어 찍지 않습니다.
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true));
    }
    return ApiClient(dio);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(baseUrl: baseUrl);
});
