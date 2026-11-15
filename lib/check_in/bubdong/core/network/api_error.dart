import 'package:dio/dio.dart';

/// 서버가 보낸 에러 문구 (400·409처럼 사용자에게 보여줄 수 있는 것만, 없으면 null)
String? serverErrorMessage(Object error) {
  if (error is! DioException) return null;
  final response = error.response;
  final status = response?.statusCode;
  if (status == null || status < 400 || status >= 500) return null;
  final data = response!.data;
  if (data is Map && data['message'] is String) return data['message'] as String;
  return null;
}
