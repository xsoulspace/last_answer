/// Permission round-trips as doc data (ADR 0005 §2/§5): a pending host
/// permission is announced as one op on the `perm/<requestId>` register
/// and answered by a second op on the SAME register — the whole lifecycle
/// is event-sourced and the kernel owns ordering/dedupe (LWW: the answer
/// is issued causally after the request, so the HLC watermark guarantees
/// it wins the register on every replica).
///
/// Pure Dart — no Flutter dependencies (headless_core law).
library;

/// Lifecycle of one permission round-trip: `pending` until an answer op
/// lands; `allow`/`reject` afterwards (deny-by-default is the absence of
/// an answer — no answer op, no completion).
enum PermRequestStatus { pending, allow, reject }

String _statusToJson(final PermRequestStatus status) => switch (status) {
  PermRequestStatus.pending => 'pending',
  PermRequestStatus.allow => 'allow',
  PermRequestStatus.reject => 'reject',
};

PermRequestStatus _statusFromJson(final String raw) => switch (raw) {
  'pending' => PermRequestStatus.pending,
  'allow' => PermRequestStatus.allow,
  'reject' => PermRequestStatus.reject,
  _ => throw ArgumentError.value(raw, 'status', 'Unknown perm status'),
};

/// One folded `perm/<requestId>` register: the request (title, origin,
/// created-at) plus — once answered — the responder identity and outcome.
/// Immutable value; an answer REPLACES the register with a new record
/// that carries the request fields forward.
final class PermRequestRecord {
  const PermRequestRecord({
    required this.requestId,
    required this.title,
    required this.originPeerId,
    required this.createdAt,
    this.originActorId,
    this.status = PermRequestStatus.pending,
    this.responderPeerId,
    this.responderActorId,
    this.answeredAt,
  }) : assert(requestId.length > 0, 'requestId is required'),
       assert(title.length > 0, 'title is required'),
       assert(originPeerId.length > 0, 'originPeerId is required');

  factory PermRequestRecord.fromJson(final Map<String, dynamic> json) =>
      PermRequestRecord(
        requestId: json['requestId'] as String,
        title: json['title'] as String,
        originPeerId: json['originPeerId'] as String,
        originActorId: json['originActorId'] as String?,
        createdAt: json['createdAt'] as String? ?? '',
        status: json['status'] == null
            ? PermRequestStatus.pending
            : _statusFromJson(json['status'] as String),
        responderPeerId: json['responderPeerId'] as String?,
        responderActorId: json['responderActorId'] as String?,
        answeredAt: json['answeredAt'] as String?,
      );

  /// Tolerant read: null for anything that is not a well-formed record —
  /// a malformed remote payload must not take the projection down
  /// (DESIGN §6); the op stays in the doc for inspection.
  static PermRequestRecord? tryFromJson(final Object? raw) {
    if (raw is! Map) return null;
    try {
      return PermRequestRecord.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } on Object {
      return null;
    }
  }

  /// Stable id of the round-trip (the register's key suffix).
  final String requestId;

  /// What the write/edit asks for — rendered verbatim on the PERM row.
  final String title;

  /// The device whose harness raised the request (the peer id of the
  /// announcing replica). A remote row is one announced by ANOTHER peer.
  final String originPeerId;

  /// The acting agent's roster actor id, when the announcing device could
  /// attribute one (ADR 0007: identity, never authority — the label only).
  final String? originActorId;

  /// When the request was announced (ISO-8601 UTC; string-ordered).
  final String createdAt;

  final PermRequestStatus status;

  /// Who answered (peer id of the answering device); null while pending.
  final String? responderPeerId;

  /// The answering actor's roster id, when attributable.
  final String? responderActorId;

  /// When the answer was issued (ISO-8601 UTC); null while pending.
  final String? answeredAt;

  bool get isPending => status == PermRequestStatus.pending;

  /// The answer record: the request fields carried forward, the outcome
  /// and responder identity attached. Rejecting is the conservative
  /// outcome and is recorded as data like any other (DESIGN §4).
  PermRequestRecord answered({
    required final bool allow,
    required final String responderPeerId,
    required final String at,
    final String? responderActorId,
  }) => PermRequestRecord(
    requestId: requestId,
    title: title,
    originPeerId: originPeerId,
    originActorId: originActorId,
    createdAt: createdAt,
    status: allow ? PermRequestStatus.allow : PermRequestStatus.reject,
    responderPeerId: responderPeerId,
    responderActorId: responderActorId,
    answeredAt: at,
  );

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'title': title,
    'originPeerId': originPeerId,
    'createdAt': createdAt,
    if (originActorId != null) 'originActorId': originActorId,
    'status': _statusToJson(status),
    if (responderPeerId != null) 'responderPeerId': responderPeerId,
    if (responderActorId != null) 'responderActorId': responderActorId,
    if (answeredAt != null) 'answeredAt': answeredAt,
  };

  @override
  String toString() =>
      'PermRequestRecord($requestId, $title, origin: $originPeerId/'
      '${originActorId ?? '·'}, ${_statusToJson(status)}'
      '${responderPeerId == null ? '' : ' by $responderPeerId'})';
}
