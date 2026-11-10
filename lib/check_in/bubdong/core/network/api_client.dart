import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env.bubdong`의 서버 주소. 없으면 바로 에러를 내서 잘못된 곳으로 요청하지 않게 함
String get baseUrl {
  final url = dotenv.maybeGet('API_BASE_URL');
  if (url == null || url.isEmpty) {
    throw StateError('.env.bubdong에 API_BASE_URL이 없습니다');
  }
  return url;
}

/// 앱 시작 때 불러서 주소가 있는지 먼저 확인
void ensureBaseUrl() => baseUrl;

/// 서버 요청 공통 설정. 실제 요청은 각 repository가 보냄
class BubdongApiClient {
  final Dio dio;

  BubdongApiClient(this.dio) {
    dio.interceptors.add(_rejectHtmlResponse);
  }

  /// 서버는 JSON만 주므로, HTML이 오면 와이파이 로그인 페이지 같은 가짜 응답으로 보고 실패 처리
  static final _rejectHtmlResponse = InterceptorsWrapper(
    onResponse: (response, handler) {
      final contentType = response.headers.value(Headers.contentTypeHeader);
      if (contentType?.toLowerCase().startsWith('text/html') ?? false) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            message: '서버가 아닌 곳에서 온 HTML 응답입니다',
          ),
        );
        return;
      }
      handler.next(response);
    },
  );

  static const Duration _timeout = Duration(seconds: 10);

  factory BubdongApiClient.create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        contentType: Headers.jsonContentType,
      ),
    );
    // 디버그일 때만 응답을 콘솔에 찍음 (요청 본문은 개인정보라 안 찍음)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true));
    }
    return BubdongApiClient(dio);
  }
}

final bubdongApiClient = BubdongApiClient.create(baseUrl: baseUrl);