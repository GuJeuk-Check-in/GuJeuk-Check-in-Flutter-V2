import 'dart:async';

import 'package:dio/dio.dart';

/// 같은 회원·시각·목적의 기록이 이미 있다는 409의 `message`.
const _duplicateLogMessage = '이미 해당 시간의 로그가 존재합니다.';

/// 나중에 다시 보내면 성공할 수 있는 실패인지.
/// 응답이 없거나 5xx면 서버나 네트워크 문제이고, 4xx는 다시 보내도 결과가 같습니다.
bool isRetryableFailure(Object error) {
  if (error is TimeoutException) return true;
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  return status == null || status >= 500;
}

/// 서버에 이미 기록이 있어 완료로 보면 되는 실패인지.
bool isDuplicateLog(Object error) =>
    error is DioException && conflictMessageOf(error) == _duplicateLogMessage;

/// 409는 여러 이유가 같은 상태 코드로 오므로 `message`로 나눕니다.
String? conflictMessageOf(DioException e) {
  final response = e.response;
  if (response?.statusCode != 409) return null;
  final data = response!.data;
  return data is Map<String, dynamic> ? data['message'] as String? : null;
}
