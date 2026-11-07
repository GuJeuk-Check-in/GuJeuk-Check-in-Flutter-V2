import 'dart:convert';

/// 큐에 담긴 접수의 종류. 재전송할 HA API를 정합니다.
enum OutboxKind { checkIn, signUp }

enum OutboxStatus {
  /// 보낼 차례를 기다립니다.
  pending,

  /// 지금 보내는 중입니다. 재전송은 이 상태인 건을 건너뜁니다.
  sending,

  /// 실패했습니다. [OutboxRecord.nextRetryAt]이 null이면 더 보내지 않습니다.
  failed,
}

/// 기기에 저장해 둔 접수 한 건.
/// [body]는 처음 만든 HA 요청 그대로 보냅니다. 내용이 달라지면 서버가 같은 ID를 409로 거절합니다.
class OutboxRecord {
  final String clientRecordId;
  final OutboxKind kind;
  final String body;
  final OutboxStatus status;
  final int attempts;
  final DateTime? nextRetryAt;
  final DateTime createdAt;
  final DateTime? failedAt;

  const OutboxRecord({
    required this.clientRecordId,
    required this.kind,
    required this.body,
    required this.status,
    required this.createdAt,
    this.attempts = 0,
    this.nextRetryAt,
    this.failedAt,
  });

  /// 더 보내지 않고 보관만 하는 실패 건인지.
  bool get isPermanentlyFailed =>
      status == OutboxStatus.failed && nextRetryAt == null;

  OutboxRecord markSending() => _copy(status: OutboxStatus.sending);

  OutboxRecord markPending(DateTime retryAt) =>
      _copy(status: OutboxStatus.pending, nextRetryAt: retryAt);

  OutboxRecord markRetry(DateTime retryAt, DateTime now) => _copy(
    status: OutboxStatus.failed,
    attempts: attempts + 1,
    nextRetryAt: retryAt,
    failedAt: now,
  );

  OutboxRecord markPermanentlyFailed(DateTime now) => _copy(
    status: OutboxStatus.failed,
    attempts: attempts + 1,
    nextRetryAt: null,
    failedAt: now,
  );

  static const _keep = Object();

  OutboxRecord _copy({
    required OutboxStatus status,
    int? attempts,
    Object? nextRetryAt = _keep,
    DateTime? failedAt,
  }) {
    return OutboxRecord(
      clientRecordId: clientRecordId,
      kind: kind,
      body: body,
      status: status,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      nextRetryAt: identical(nextRetryAt, _keep)
          ? this.nextRetryAt
          : nextRetryAt as DateTime?,
      failedAt: failedAt ?? this.failedAt,
    );
  }

  String encode() => jsonEncode({
    'clientRecordId': clientRecordId,
    'kind': kind.name,
    'body': body,
    'status': status.name,
    'attempts': attempts,
    'nextRetryAt': nextRetryAt?.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'failedAt': failedAt?.millisecondsSinceEpoch,
  });

  factory OutboxRecord.decode(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return OutboxRecord(
      clientRecordId: json['clientRecordId'] as String,
      kind: OutboxKind.values.byName(json['kind'] as String),
      body: json['body'] as String,
      status: OutboxStatus.values.byName(json['status'] as String),
      attempts: json['attempts'] as int,
      nextRetryAt: _dateOf(json['nextRetryAt'] as int?),
      createdAt: _dateOf(json['createdAt'] as int)!,
      failedAt: _dateOf(json['failedAt'] as int?),
    );
  }

  static DateTime? _dateOf(int? millis) =>
      millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
}
