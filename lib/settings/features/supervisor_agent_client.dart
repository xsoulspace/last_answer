/// The client seam the app-open AGENT automations use to reach the
/// authorized harness world (the ECS world) — through the app's EXISTING
/// harness client. No second executor, no second protocol, no second
/// authority.
///
/// Two laws ride this file:
///
/// - THE CREATION RECEIPT IS NOT A COMPLETION. `task op:create` answers
///   `state: queued`: the world admitted the task, it did not run it.
///   The terminal truth is the durable task record the world keeps,
///   read back through `task {op:'show'}` (ADR 0118 D3/D5 — one
///   delegation concept, and the queue record is its authority). A
///   client that stops at the receipt fabricates success.
///
/// - A REFUSAL IS DATA. The world's own bounce code is carried verbatim
///   ([SupervisorAgentRefusal.code]); it is never rewritten into a
///   generic failure and never substituted by another provider.
library;

import 'dart:convert' show jsonEncode;

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
  String toString() =>
      detail == null || detail!.isEmpty ? code : '$code: $detail';
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

  /// The world's anchor beat for the task's durable record
  /// (`control:task:<id>`), kept as the run's identity token.
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
  ///
  /// [modelId] is a PALETTE ENTRY id (leg B G3): omitted, the world
  /// defaults to its primary generative rung — a degraded primary the
  /// surface should have shown BEFORE the send. [addressees] are the
  /// actor ids the task is addressed to (ADR 0118: the addressing IS
  /// the delegation).
  Future<SupervisorAgentAdmission> admit({
    required String task,
    required String requestId,
    String? modelId,
    List<String>? addressees,
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
  const SupervisorAgentClientResolution.available(this.client, {this.release})
    : refusal = null;

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

/// The client over the app's existing harness client: the world's
/// universal task surface (`task` op:`create` / `show` / `cancel`,
/// ADR 0118 D3/D5). Creation IS the delegation — the addressing is the
/// delegation — and the durable truth is the queue record itself, read
/// back through `task {op:'show'}`.
final class HarnessWorldAgentClient implements SupervisorAgentClient {
  HarnessWorldAgentClient({required this.call, this.allowedTools});

  /// The app's existing harness client: one allowlisted tool call.
  final SupervisorHarnessCall call;

  /// The live catalog this client may use — the seat's own tool
  /// allowlist. Null means "no catalog to check" (an embedded client
  /// that serves the whole surface). A tool outside the catalog is
  /// refused by name BEFORE the call: the gap is reported, never
  /// approximated by another verb.
  final Set<String>? allowedTools;

  @override
  Future<SupervisorAgentAdmission> admit({
    required final String task,
    required final String requestId,
    final String? modelId,
    final List<String>? addressees,
  }) async {
    final result = await _invoke('task', {
      'op': 'create',
      'task': task,
      'requestId': requestId,
      'purpose': 'coding',
      if (modelId != null && modelId.isNotEmpty) 'modelId': modelId,
      if (addressees != null && addressees.isNotEmpty) 'addressees': addressees,
    });
    if (result['ok'] != true) {
      throw SupervisorAgentRefusal(_bounceOf(result) ?? 'task_create_refused');
    }
    final taskId = result['taskId'];
    final beatId = result['admissionBeatId'];
    if (taskId is! String ||
        taskId.isEmpty ||
        beatId is! String ||
        beatId.isEmpty) {
      throw const SupervisorAgentRefusal('task_create_receipt_incomplete');
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
  }) async {
    final receipt = await _invoke('task', {
      'op': 'show',
      'taskId': admission.taskId,
    });
    if (receipt['ok'] != true) {
      throw SupervisorAgentRefusal(
        _bounceOf(receipt) ?? 'task_state_unreadable',
      );
    }
    return _outcomeOf(receipt);
  }

  @override
  Future<SupervisorAgentOutcome> cancel({
    required final SupervisorAgentAdmission admission,
    required final String requestId,
  }) async {
    // The world's cancellation is authoritative on the task record
    // (`cancelRequested` on the queue row, ADR 0114) and idempotent —
    // the request id is not part of the op; the join is the receipt
    // read that follows.
    final result = await _invoke('task', {
      'op': 'cancel',
      'taskId': admission.taskId,
    });
    if (result['ok'] != true) {
      throw SupervisorAgentRefusal(_bounceOf(result) ?? 'task_cancel_refused');
    }
    return outcome(admission: admission);
  }

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

  /// Maps the world's own task receipt onto an outcome. The state words
  /// are the queue's (`queued`, `leased`, `started`, `succeeded`,
  /// `failed`, `cancelled`, `unknown`); a settled task carries a
  /// terminal record the world wrote — never one we infer.
  SupervisorAgentOutcome _outcomeOf(final Map<String, Object?> receipt) {
    final state = '${receipt['state'] ?? ''}';
    final terminal = receipt['terminal'];
    final terminalMap = terminal is Map
        ? Map<String, Object?>.from(terminal)
        : const <String, Object?>{};
    final terminalState = '${terminalMap['state'] ?? state}';
    final isTerminal =
        terminalMap.isNotEmpty ||
        const {'succeeded', 'failed', 'cancelled', 'unknown'}.contains(state);
    final cancelled = terminalState == 'cancelled' || state == 'cancelled';
    final succeeded = terminalState == 'succeeded';
    final failure = switch (terminalState) {
      'failed' => switch (terminalMap['reason']) {
        final String reason when reason.isNotEmpty => reason,
        _ => 'failed',
      },
      'unknown' => 'outcome_unknown',
      _ => null,
    };
    return SupervisorAgentOutcome(
      state: state,
      terminal: isTerminal,
      succeeded: succeeded,
      cancelled: cancelled,
      failure: failure,
      detail: _detailOf(receipt),
      raw: receipt,
    );
  }
}

String? _detailOf(final Map<String, Object?> receipt) {
  final terminal = receipt['terminal'];
  if (terminal is! Map) return null;
  final result = terminal['result'];
  if (result is Map) {
    final summary = result['summary'];
    if (summary is String && summary.isNotEmpty) return summary;
  }
  final reason = terminal['reason'];
  if (reason is String && reason.isNotEmpty) return reason;
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
