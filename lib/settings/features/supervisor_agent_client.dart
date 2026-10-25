/// The client seam the app-open AGENT automations use to reach the
/// authorized harness world (the ECS world) — through the app's EXISTING
/// harness client. No second executor, no second protocol, no second
/// authority.
///
/// Two laws ride this file:
///
/// - THE DELEGATION RECEIPT IS NOT A COMPLETION. `task_delegate` answers
///   `state: queued`: the world admitted the task, it did not run it.
///   The terminal truth is the durable delegation state the world keeps
///   on the admission beat, read back through
///   `agent_context {op:'read', field:'tool_output'}`. A client that
///   stops at the receipt fabricates success.
///
/// - A REFUSAL IS DATA. The world's own bounce code is carried verbatim
///   ([SupervisorAgentRefusal.code]); it is never rewritten into a
///   generic failure and never substituted by another provider.
library;

import 'dart:convert';

/// One allowlisted harness tool call over the app's existing client —
/// the same shape the world inspector's seat uses
/// (`agent_context`, `agent_participation`).
typedef SupervisorHarnessCall =
    Future<Map<String, Object?>> Function(
      String tool,
      Map<String, Object?> args,
    );

/// A named refusal from the world (or from the seat that carries it).
/// The [code] is the world's own vocabulary — kept verbatim so the
/// surface can say WHY the automation did not run.
final class SupervisorAgentRefusal implements Exception {
  const SupervisorAgentRefusal(this.code, {this.detail});

  final String code;
  final String? detail;

  @override
  String toString() => detail == null || detail!.isEmpty
      ? code
      : '$code: $detail';
}

/// The world's admission of one delegated task. [state] is the world's
/// own state word at admission time (`queued`); it is NOT an outcome.
final class SupervisorAgentAdmission {
  const SupervisorAgentAdmission({
    required this.taskId,
    required this.admissionBeatId,
    required this.state,
    this.raw = const {},
  });

  /// The world's task id — the durable handle of the delegated work.
  final String taskId;

  /// The beat that carries the delegation's durable state. The world's
  /// own store keeps it; reading it is how completion is proven.
  final String admissionBeatId;

  /// The world state at admission (`queued`, `started`, …).
  final String state;

  /// The raw receipt, kept for the surface (never for authority).
  final Map<String, Object?> raw;
}

/// What the world says about a delegated task NOW.
final class SupervisorAgentOutcome {
  const SupervisorAgentOutcome({
    required this.state,
    required this.terminal,
    required this.succeeded,
    this.cancelled = false,
    this.failure,
    this.detail,
    this.raw = const {},
  });

  /// The world's own state word (`queued`, `started`, `verifying`,
  /// `loop_settled`, `cancelled`, `outcome_unknown`).
  final String state;

  /// True when the world reached a terminal state — the delegation is
  /// over, one way or the other.
  final bool terminal;

  /// True only when the world VERIFIED the delegated work
  /// (`goalCompletionVerified`). Never inferred from a receipt.
  final bool succeeded;

  /// True when the world cancelled the delegation.
  final bool cancelled;

  /// The failure the world recorded (`failureClass` / `failureDetail`).
  final String? failure;

  /// A human line about the outcome.
  final String? detail;

  /// The durable delegation state, verbatim.
  final Map<String, Object?> raw;

  /// One line for the log.
  String get describe {
    final parts = <String>[state];
    if (succeeded) parts.add('verified');
    if (cancelled) parts.add('cancelled');
    if (failure != null) parts.add('failed: $failure');
    if (detail != null && detail!.isNotEmpty) parts.add(detail!);
    return parts.join(' · ');
  }
}

/// The client an agent automation runs through. The implementation is the
/// app's existing harness client; the interface is what the supervisor
/// provider needs, and nothing more.
abstract interface class SupervisorAgentClient {
  /// Asks the world to admit [task]. The answer is an ADMISSION, never a
  /// completion: the returned [SupervisorAgentAdmission.state] is the
  /// world's word at admission time.
  Future<SupervisorAgentAdmission> admit({
    required String task,
    required String requestId,
  });

  /// Reads the durable state of an admitted task.
  Future<SupervisorAgentOutcome> outcome({
    required SupervisorAgentAdmission admission,
  });

  /// Cancels an admitted task and joins the world's own cancellation.
  Future<SupervisorAgentOutcome> cancel({
    required SupervisorAgentAdmission admission,
    required String requestId,
  });
}

/// Where the provider gets its client: the app's EXISTING harness client
/// for the world that is currently authorized. The client is resolved
/// when the automation actually runs (the seat is earned then), so a
/// world that is not reachable refuses AT THE RUN, in words.
typedef SupervisorAgentClientResolver =
    Future<SupervisorAgentClientResolution> Function();

/// The outcome of asking for a client: the client, or the EXACT reason
/// the capability is not there. A refusal is never a silent null — and
/// it never claims the capability is qualified: it names what the world
/// (or the seat) did or did not serve.
final class SupervisorAgentClientResolution {
  const SupervisorAgentClientResolution.available(
    this.client, {
    this.release,
  }) : refusal = null;

  const SupervisorAgentClientResolution.refused(this.refusal)
    : client = null,
      release = null;

  /// The client, when the world served one.
  final SupervisorAgentClient? client;

  /// The exact reason the capability is absent, in words.
  final String? refusal;

  /// Releases the seat (or whatever the client holds) when the app is
  /// done with it. Null when there is nothing to release.
  final Future<void> Function()? release;

  bool get available => client != null;
}

/// The client over the app's existing harness client: the participation
/// verbs (`task_delegate`, `task_cancel`) and the context read that
/// returns the world's durable delegation state.
final class HarnessWorldAgentClient implements SupervisorAgentClient {
  HarnessWorldAgentClient({
    required this.call,
    this.pageLimit = 32768,
    this.allowedTools,
  });

  /// The app's existing harness client: one allowlisted tool call.
  final SupervisorHarnessCall call;

  /// The live catalog this client may use — the seat's own tool
  /// allowlist. Null means "no catalog to check" (an embedded client
  /// that serves the whole surface). A verb outside the catalog is
  /// refused by name BEFORE the call: the gap is reported, never
  /// approximated by another verb.
  final Set<String>? allowedTools;

  /// The page size for the durable-state read (the harness serves the
  /// beat's tool output in pages; the world refuses a page above 64000
  /// characters with `invalid_page`).
  final int pageLimit;

  @override
  Future<SupervisorAgentAdmission> admit({
    required final String task,
    required final String requestId,
  }) async {
    final result = await _invoke('agent_participation', {
      'op': 'task_delegate',
      'task': task,
      'requestId': requestId,
      'purpose': 'coding',
    });
    if (result['ok'] != true) {
      throw SupervisorAgentRefusal(
        _bounceOf(result) ?? 'task_delegate_refused',
      );
    }
    final taskId = result['taskId'];
    final beatId = result['admissionBeatId'];
    if (taskId is! String ||
        taskId.isEmpty ||
        beatId is! String ||
        beatId.isEmpty) {
      throw const SupervisorAgentRefusal('task_delegate_receipt_incomplete');
    }
    return SupervisorAgentAdmission(
      taskId: taskId,
      admissionBeatId: beatId,
      state: '${result['state'] ?? ''}',
      raw: result,
    );
  }

  @override
  Future<SupervisorAgentOutcome> outcome({
    required final SupervisorAgentAdmission admission,
  }) async => _outcomeOf(await _readDelegation(admission));

  @override
  Future<SupervisorAgentOutcome> cancel({
    required final SupervisorAgentAdmission admission,
    required final String requestId,
  }) async {
    final result = await _invoke('agent_participation', {
      'op': 'task_cancel',
      'taskId': admission.taskId,
      'requestId': requestId,
    });
    if (result['ok'] != true) {
      throw SupervisorAgentRefusal(
        _bounceOf(result) ?? 'task_cancel_refused',
      );
    }
    return outcome(admission: admission);
  }

  /// The world's own read page ceiling (`invalid_page` above it).
  static const int _maxPage = 64000;

  /// One catalog-checked call over the app's existing client.
  Future<Map<String, Object?>> _invoke(
    final String tool,
    final Map<String, Object?> args,
  ) {
    final allowed = allowedTools;
    if (allowed != null && !allowed.contains(tool)) {
      throw SupervisorAgentRefusal('seat_tool_unavailable', detail: tool);
    }
    return call(tool, args);
  }

  /// Reads the delegation's durable state — the world's own record of the
  /// delegated work, page by page, exactly as the harness serves it.
  Future<Map<String, Object?>> _readDelegation(
    final SupervisorAgentAdmission admission,
  ) async {
    final beat = admission.admissionBeatId;
    final buffer = StringBuffer();
    var offset = 0;
    int? total;
    while (true) {
      final Map<String, Object?> page;
      try {
        page = await _invoke('agent_context', {
          'op': 'read',
          'beat': beat,
          'field': 'tool_output',
          'offset': offset,
          'limit': pageLimit.clamp(1, _maxPage),
        });
      } on Object catch (error) {
        throw SupervisorAgentRefusal(
          'delegation_state_unreadable',
          detail: '$error',
        );
      }
      if (page['ok'] != true) {
        throw SupervisorAgentRefusal(
          _bounceOf(page) ?? 'delegation_state_unreadable',
        );
      }
      if (page['beatId'] != beat) {
        throw const SupervisorAgentRefusal('delegation_beat_mismatch');
      }
      if (page['field'] != 'tool_output') {
        throw const SupervisorAgentRefusal('delegation_state_field_mismatch');
      }
      if (page['offsetUnit'] != 'utf16_code_units') {
        throw const SupervisorAgentRefusal('delegation_state_offset_unit');
      }
      final text = page['text'];
      if (text is! String) {
        throw const SupervisorAgentRefusal('delegation_state_empty');
      }
      final length = page['totalLength'];
      if (length is! int || length < 0) {
        throw const SupervisorAgentRefusal('delegation_state_length_invalid');
      }
      if (total != null && total != length) {
        throw const SupervisorAgentRefusal('delegation_state_length_changed');
      }
      total = length;
      buffer.write(text);
      if (page['truncated'] != true) break;
      final next = page['nextOffset'];
      if (next is! int || next <= offset) {
        throw const SupervisorAgentRefusal(
          'delegation_state_next_offset_invalid',
        );
      }
      offset = next;
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(buffer.toString());
    } on FormatException catch (error) {
      throw SupervisorAgentRefusal(
        'delegation_state_invalid',
        detail: error.message,
      );
    }
    if (decoded is! Map) {
      throw const SupervisorAgentRefusal('delegation_state_invalid');
    }
    return Map<String, Object?>.from(decoded);
  }

  /// Maps the world's durable delegation state onto an outcome. The
  /// terminal words and the verification flag are the world's, not ours.
  SupervisorAgentOutcome _outcomeOf(final Map<String, Object?> data) {
    final state = '${data['state'] ?? ''}';
    final acceptance = data['goalAcceptance'];
    final acceptanceMap = acceptance is Map
        ? Map<String, Object?>.from(acceptance)
        : const <String, Object?>{};
    final verified = acceptanceMap['goalCompletionVerified'] == true;
    final acceptanceFailed = acceptanceMap['status'] == 'failed';
    final failureClass = data['failureClass'];
    final failureDetail = data['failureDetail'];
    final failure = failureClass is String && failureClass.isNotEmpty
        ? (failureDetail is String && failureDetail.isNotEmpty
              ? '$failureClass: $failureDetail'
              : failureClass)
        : (acceptanceFailed ? 'acceptance_failed' : null);
    final terminal = switch (state) {
      'loop_settled' || 'cancelled' || 'outcome_unknown' => true,
      _ => failure != null,
    };
    final cancelled = state == 'cancelled';
    final succeeded = state == 'loop_settled' && verified;
    return SupervisorAgentOutcome(
      state: state,
      terminal: terminal,
      succeeded: succeeded,
      cancelled: cancelled,
      failure: failure,
      detail: _detailOf(data),
      raw: data,
    );
  }
}

String? _detailOf(final Map<String, Object?> data) {
  final acceptance = data['goalAcceptance'];
  if (acceptance is Map) {
    final status = acceptance['status'];
    if (status is String && status.isNotEmpty) return status;
  }
  final detail = data['failureDetail'];
  if (detail is String && detail.isNotEmpty) return detail;
  return null;
}

/// The world's refusal code, verbatim. A bounce may be a string or a map
/// carrying `code`; anything else falls back to `error`.
String? _bounceOf(final Map<String, Object?> result) {
  final bounce = result['bounce'];
  if (bounce is String && bounce.isNotEmpty) return bounce;
  if (bounce is Map) {
    final code = bounce['code'];
    if (code is String && code.isNotEmpty) return code;
    return jsonEncode(bounce);
  }
  final error = result['error'];
  if (error is String && error.isNotEmpty) return error;
  return null;
}
