import 'dart:async';

import 'package:dio/dio.dart';

/// 같은 회원·시각·목적의 기록이 이미 있다는 409의 `message`.
const _duplicateLogMessage = '이미 해당 시간의 로그가 존재합니다.';

/// 내용과 상관없이 잠시 뒤 풀리는 4xx. 시간 초과, 재전송 위험, 요청 제한입니다.
const _temporaryClientErrors = {408, 425, 429};

/// 서버가 내용을 보고 거절하는 4xx.
const _contentRejections = {400, 409, 422};

/// 나중에 다시 보내면 성공할 수 있는 실패인지.
/// 응답이 없거나 3xx, 5xx, [_temporaryClientErrors]면 서버나 네트워크 문제입니다.
bool isRetryableFailure(Object error) {
  if (error is TimeoutException) return true;
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  return status == null ||
      status < 400 ||
      status >= 500 ||
      _temporaryClientErrors.contains(status);
}

/// 서버가 내용을 거절해 같은 내용을 다시 보내도 소용없는 실패인지.
bool isContentRejection(Object error) =>
    error is DioException &&
    _contentRejections.contains(error.response?.statusCode);

bool isBadRequest(Object error) =>
    error is DioException && error.response?.statusCode == 400;

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
