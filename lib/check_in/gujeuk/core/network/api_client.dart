import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/server_clock.dart';

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

  /// [clock]이 있으면 서버 응답의 시각으로 보정합니다.
  /// HTML을 먼저 거르므로 캡티브 포털의 시각으로 보정하지 않습니다.
  ApiClient(this.dio, {ServerClock? clock}) {
    dio.interceptors.add(_rejectHtmlResponse);
    if (clock != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            clock.syncWithDateHeader(response.headers.value('date'));
            handler.next(response);
          },
        ),
      );
    }
  }

  /// 서버는 HTML로 답하지 않으므로 2xx HTML은 캡티브 포털이나 프록시가 대신 답한 것입니다.
  /// 응답 없는 실패로 만들어 서버에 닿지 못한 요청과 똑같이 다룹니다.
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

  factory ApiClient.create({required String baseUrl, ServerClock? clock}) {
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
    return ApiClient(dio, clock: clock);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(
    baseUrl: baseUrl,
    clock: ref.watch(serverClockProvider),
  );
});
