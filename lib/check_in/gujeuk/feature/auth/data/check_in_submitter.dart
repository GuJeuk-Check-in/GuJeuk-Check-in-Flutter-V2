import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_failure.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/phone_number_formatter.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/utils/server_date_format.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/local_outbox_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/outbox_sync_service.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_sign_up_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/check_in_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_record.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/outbox_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/sign_up_repository.dart';
import 'package:uuid/uuid.dart';

/// 예약 없는 접수를 기기에 먼저 저장하고 서버로 보냅니다.
/// 끝나면 접수가 완료된 것이고, 서버 연결 문제면 저장해 둔 채로 나중에 다시 보냅니다.
/// 저장에 실패하거나 서버가 내용을 거절하면 예외를 던집니다.
class CheckInSubmitter {
  /// 키오스크 앞에서 기다리는 최대 시간. 넘으면 저장해 둔 채 완료 화면으로 넘어갑니다.
  static const _firstSendLimit = Duration(seconds: 5);

  final OutboxRepository _outbox;
  final CheckInRepository _checkIns;
  final SignUpRepository _signUps;
  final DateTime Function() _now;
  final String Function() _newId;

  CheckInSubmitter(
    this._outbox,
    this._checkIns,
    this._signUps, {
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? const Uuid().v4;

  /// 다시 온 친구의 방문 기록.
  Future<void> submitCheckIn({
    required int userId,
    required String purpose,
    required int maleCount,
    required int femaleCount,
  }) async {
    final visitTime = _now();
    final clientRecordId = _newId();
    final record = _newRecord(
      clientRecordId,
      OutboxKind.checkIn,
      visitTime,
      OutboxStatus.sending,
      {
        'clientRecordId': clientRecordId,
        'id': userId,
        'purpose': purpose,
        'maleCount': maleCount,
        'femaleCount': femaleCount,
        'visitTime': ServerDateFormat.dateTime(visitTime),
      },
    );
    await _outbox.save(record);
    await _sendFirst(
      record,
      () => _checkIns.checkIn(
        userId: userId,
        purpose: purpose,
        maleCount: maleCount,
        femaleCount: femaleCount,
        visitTime: visitTime,
        clientRecordId: clientRecordId,
      ),
    );
  }

  /// 처음 온 친구의 가입. 예약 시간이 있는 가입은 큐에 넣지 않고 [SignUpRepository]로 바로 보냅니다.
  Future<void> submitSignUp({
    required String name,
    required Gender gender,
    required String phone,
    required DateTime birthDate,
    required String residence,
    required String purpose,
    required int maleCount,
    required int femaleCount,
  }) async {
    final visitTime = _now();
    final record = _signUpRecord(
      name: name,
      gender: gender,
      phone: phone,
      birthDate: birthDate,
      residence: residence,
      purpose: purpose,
      maleCount: maleCount,
      femaleCount: femaleCount,
      visitTime: visitTime,
      status: OutboxStatus.sending,
    );
    await _outbox.save(record);
    await _sendFirst(
      record,
      () => _signUps.signUp(
        name: name,
        gender: gender,
        phone: phone,
        birthDate: birthDate,
        residence: residence,
        purpose: purpose,
        maleCount: maleCount,
        femaleCount: femaleCount,
        visitTime: visitTime,
      ),
    );
  }

  /// 이름 확인이 실패해 회원인지 모르는 친구의 접수. 서버가 이름으로 회원을 찾거나 새로 만듭니다.
  /// 서버가 응답하지 않는 때이므로 바로 보내지 않고 저장만 합니다.
  Future<void> queueUnknownVisitor({
    required String name,
    required Gender gender,
    required String phone,
    required DateTime birthDate,
    required String residence,
    required String purpose,
    required int maleCount,
    required int femaleCount,
  }) {
    return _outbox.save(
      _signUpRecord(
        name: name,
        gender: gender,
        phone: phone,
        birthDate: birthDate,
        residence: residence,
        purpose: purpose,
        maleCount: maleCount,
        femaleCount: femaleCount,
        visitTime: _now(),
        status: OutboxStatus.pending,
      ),
    );
  }

  OutboxRecord _signUpRecord({
    required String name,
    required Gender gender,
    required String phone,
    required DateTime birthDate,
    required String residence,
    required String purpose,
    required int maleCount,
    required int femaleCount,
    required DateTime visitTime,
    required OutboxStatus status,
  }) {
    final clientRecordId = _newId();
    return _newRecord(clientRecordId, OutboxKind.signUp, visitTime, status, {
      'clientRecordId': clientRecordId,
      'name': name,
      'phone': PhoneNumberFormatter.format(phone),
      'gender': gender.serverValue,
      'birthYMD': ServerDateFormat.date(birthDate),
      // 서버의 HA 가입은 나이대를 계산하지 않고 받은 값을 저장합니다.
      'age': ageGroupOf(birthDate, visitTime),
      'residence': residence,
      // 동의하지 않으면 폼 검사에서 막히므로 여기까지 오면 항상 동의한 것입니다.
      'privacyAgreed': true,
      'maleCount': maleCount,
      'femaleCount': femaleCount,
      'purpose': purpose,
      'visitTime': ServerDateFormat.dateTime(visitTime),
    });
  }

  OutboxRecord _newRecord(
    String clientRecordId,
    OutboxKind kind,
    DateTime visitTime,
    OutboxStatus status,
    Map<String, Object> body,
  ) {
    return OutboxRecord(
      clientRecordId: clientRecordId,
      kind: kind,
      body: jsonEncode(body),
      status: status,
      createdAt: visitTime,
      nextRetryAt: status == OutboxStatus.pending ? visitTime : null,
    );
  }

  Future<void> _sendFirst(
    OutboxRecord record,
    Future<void> Function() send,
  ) async {
    try {
      await send().timeout(_firstSendLimit);
    } on Exception catch (error) {
      if (isDuplicateLog(error)) {
        await _settle(() => _outbox.delete(record.clientRecordId));
      } else if (isRetryableFailure(error)) {
        final retryAt = _now().add(outboxFirstRetryDelay);
        await _settle(() => _outbox.save(record.markPending(retryAt)));
      } else {
        await _settle(() => _outbox.delete(record.clientRecordId));
        rethrow;
      }
      return;
    }
    await _settle(() => _outbox.delete(record.clientRecordId));
  }

  /// 접수 결과는 이미 정해졌으니 뒷정리 실패로 뒤집지 않습니다.
  /// 남은 건은 앱을 다시 시작할 때 재전송되고, 서버가 중복을 걸러 줍니다.
  Future<void> _settle(Future<void> Function() cleanup) async {
    try {
      await cleanup();
    } catch (error) {
      debugPrint('outbox: 전송 후 큐 정리 실패 (${error.runtimeType})');
    }
  }

  /// 서버 `Age`와 같은 구간. 나이는 방문 연도 기준 세는 나이입니다.
  @visibleForTesting
  static String ageGroupOf(DateTime birthDate, DateTime visitTime) {
    final age = visitTime.year - birthDate.year + 1;
    if (age <= 8) return 'BABY';
    if (age <= 13) return 'AGE_9_13';
    if (age <= 16) return 'AGE_14_16';
    if (age <= 19) return 'AGE_17_19';
    if (age <= 24) return 'AGE_20_24';
    return 'ADULT';
  }
}

final checkInSubmitterProvider = Provider<CheckInSubmitter>((ref) {
  return CheckInSubmitter(
    ref.watch(outboxRepositoryProvider),
    ref.watch(checkInRepositoryProvider),
    ref.watch(signUpRepositoryProvider),
  );
});
