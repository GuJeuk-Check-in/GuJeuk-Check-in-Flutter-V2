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

/// 보낸 목적·회원·거주지가 서버에서 지워졌다는 404의 `message`.
/// 주소가 틀렸거나 배포 중인 404는 다시 보내면 성공할 수 있어 메시지로 나눕니다.
const _goneMessages = {
  '존재하지 않는 방문목적입니다.',
  '존재하지 않는 하위 방문목적입니다.',
  '해당 유저가 존재 하지 않습니다.',
  '존재하지 않는 거주지 입니다.',
};

/// 서버가 내용을 거절해 같은 내용을 다시 보내도 소용없는 실패인지.
bool isContentRejection(Object error) {
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  if (_contentRejections.contains(status)) return true;
  return status == 404 && _goneMessages.contains(rejectionMessageOf(error));
}

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
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}

/// 서버가 요청 내용을 거절한 400·404의 `message`. 같은 상태 코드로 여러 이유가 옵니다.
String? rejectionMessageOf(DioException e) {
  final response = e.response;
  final status = response?.statusCode;
  if (status != 400 && status != 404) return null;
  final data = response!.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}
