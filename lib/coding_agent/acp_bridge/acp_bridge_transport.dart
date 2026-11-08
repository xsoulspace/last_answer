/// Item 2e (SECONDARY leg) — the ACP external-actor bridge's transport
/// seam.
///
/// The bridge ([AcpActorBridge]) rides this INTERFACE, never the
/// [AcpAgentRuntime] directly: the interface is the test seam (scripted
/// fakes answer beats without spawning an agent process) and the honest
/// boundary (everything the bridge needs from an ACP agent, and nothing
/// more — no mode switcher, no resume, no catalog).
///
/// Laws:
/// - ONE runtime per bridge: [start] spawns/attaches once; [send] rides
/// the bound session. No spawn per beat.
/// - Permission requests are [AcpBridgePermissionRequest]s — exactly
/// one answer is honored ([AcpBridgePermissionRequest.answer] guards),
/// matching [AcpPendingPermission]'s exactly-once law underneath.
/// - A stopped transport stays stopped: [stop] tears the process down;
/// later [send]s fail by name, never crash.
library;

import 'dart:async';

import 'package:lastanswer/doc/acp_agent_runtime.dart';

/// One agent `session/request_permission`, bridged: the facts the 0c
/// interrupt card renders (title/kind/details — journal facts from the
/// request, never invention) plus the exactly-once [answer] wire.
final class AcpBridgePermissionRequest {
  AcpBridgePermissionRequest({
    required this.title,
    required this.onAnswer,
    this.kind,
    this.details,
  });

  /// The agent's own request title (empty allowed — the card then shows
  /// the kind; the title is never invented here).
  final String title;

  /// The agent's own request kind (`edit`, `execute`, …), null when the
  /// request carried none.
  final String? kind;

  /// The request's optional human-facing detail block (e.g. the unified
  /// diff under review) — rides the card's `diff` slot unchanged.
  final String? details;

  final Future<void> Function(bool allow) onAnswer;

  bool _answered = false;

  /// Whether an answer already landed (a second [answer] is a no-op —
  /// the exactly-once law, guarded here AND under the runtime).
  bool get isAnswered => _answered;

  /// Answers the agent's request exactly once: allow = the agent's tool
  /// call proceeds; reject = it never lands.
  Future<void> answer({required final bool allow}) async {
    if (_answered) return;
    _answered = true;
    await onAnswer(allow);
  }
}

/// The minimal transport the bridge rides: start/stop, one session,
/// prompt turns as update streams, and the permission lane.
abstract interface class AcpBridgeTransport {
  /// Spawns/attaches the agent process once (idempotent underneath).
  Future<void> start();

  /// Opens the session the bridge's prompts ride; returns its id.
  Future<String> newSession(final String workingDirectory);

  /// One prompt turn: the agent's streamed updates (text deltas, tool
  /// statuses, plan entries) until the turn completes. Errors surface
  /// ON the stream (the bridge names them honestly in the room).
  Stream<AcpPromptUpdate> send(final String prompt);

  /// Every permission request the agent raises mid-turn.
  Stream<AcpBridgePermissionRequest> get permissionRequests;

  /// Currently unanswered requests (late-subscriber snapshot).
  List<AcpBridgePermissionRequest> get pendingPermissions;

  /// Tears the agent process down. Later [send]s fail by name.
  Future<void> stop();
}

/// The production adapter: wraps [AcpAgentRuntime] (the dart_acp_toolkit
/// client owner) into the [AcpBridgeTransport] seam. Owns ONE runtime
/// for ONE bridge; permission requests are wrapped identity-stably so
/// the stream and the snapshot agree.
final class AcpRuntimeBridgeTransport implements AcpBridgeTransport {
  AcpRuntimeBridgeTransport({
    required this.config,
    final AcpAgentRuntime? runtime,
  }) : _runtime = runtime ?? AcpAgentRuntime();

  /// The spawn configuration (from [AcpRuntimeConfig.fromInstallation]).
  final AcpRuntimeConfig config;

  final AcpAgentRuntime _runtime;
  final Map<AcpPendingPermission, AcpBridgePermissionRequest> _wrapped = {};
  final StreamController<AcpBridgePermissionRequest> _permissions =
      StreamController<AcpBridgePermissionRequest>.broadcast();
  StreamSubscription<AcpPendingPermission>? _permissionSub;
  String? _sessionId;
  bool _stopped = false;

  /// Observability: the runtime's own status word (never a guess).
  AcpRuntimeStatus get runtimeStatus => _runtime.status;

  @override
  Future<void> start() async {
    if (_stopped) throw StateError('acp_bridge_transport_stopped');
    await _runtime.start(config);
    _permissionSub ??= _runtime.permissionRequests.listen(
      (final pending) {
        if (_permissions.isClosed) return;
        _permissions.add(_wrap(pending));
      },
    );
  }

  @override
  Future<String> newSession(final String workingDirectory) async {
    if (_stopped) throw StateError('acp_bridge_transport_stopped');
    final id = await _runtime.newSession(workingDirectory);
    _sessionId = id;
    return id;
  }

  @override
  Stream<AcpPromptUpdate> send(final String prompt) {
    final sessionId = _sessionId;
    if (_stopped) {
      return Stream<AcpPromptUpdate>.error(
        StateError('acp_bridge_transport_stopped'),
      );
    }
    if (sessionId == null) {
      return Stream<AcpPromptUpdate>.error(
        StateError('acp_bridge_no_session'),
      );
    }
    return _runtime.send(prompt, sessionId: sessionId);
  }

  @override
  Stream<AcpBridgePermissionRequest> get permissionRequests =>
      _permissions.stream;

  @override
  List<AcpBridgePermissionRequest> get pendingPermissions => [
    for (final pending in _runtime.pendingPermissions) _wrap(pending),
  ];

  AcpBridgePermissionRequest _wrap(final AcpPendingPermission pending) =>
      _wrapped.putIfAbsent(
        pending,
        () => AcpBridgePermissionRequest(
          title: pending.request.title,
          kind: pending.request.kind,
          details: pending.request.details,
          onAnswer: (final allow) async {
            if (allow) {
              await pending.allow();
            } else {
              await pending.reject();
            }
          },
        ),
      );

  @override
  Future<void> stop() async {
    _stopped = true;
    _sessionId = null;
    await _permissionSub?.cancel();
    _permissionSub = null;
    await _permissions.close();
    _wrapped.clear();
    await _runtime.stop();
  }
}
