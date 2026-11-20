import 'actor_roster.dart';
import 'perm_request.dart';

/// Agent/intent projections of an open agent document (DESIGN §5: one
/// state, many projections — an agent parses these typed shapes, never a
/// screenshot). The app-side wiring contract ([`AgentDocMeshWiring`] on
/// the doc surface) and the peer-side [`AgentDocShadow`] stay with the
/// surface; these three projections are the shared vocabulary.

/// The agent/intent projection of the surface state (canonical, typed —
/// an agent parses this, never a screenshot).
final class AgentDocDebugState {
  const AgentDocDebugState({
    required this.docId,
    required this.workspaces,
    required this.backend,
    this.checkCommand = const [],
    this.runtimeProfile = 'meaning',
    this.sessionId,
    this.running = false,
    this.pendingPermissionTitle,
    this.verdict,
    this.transcriptTail = '',
    this.turnCount = 0,
    this.lastGuidance,
    this.actors = const [],
    this.sessionActors = const {},
    this.remotePermissions = const [],
    this.remotePermissionRouting = false,
    this.meshStatus,
    this.queue = const [],
    this.tasks = const [],
    this.viewer = false,
    this.meaning,
  });

  final String docId;
  final List<String> workspaces;

  /// The bound check override (the doc's `--check`, ADR 0003) — empty = the
  /// workspace convention decides.
  final List<String> checkCommand;
  final String backend;

  /// R9.1 — which tool surface the runtime speaks: `meaning` (zoom cuts,
  /// edit moves — the AFM path) or `commands` (conventional, CLI squad
  /// members only).
  final String runtimeProfile;
  final String? sessionId;
  final bool running;
  final String? pendingPermissionTitle;
  final String? verdict;
  final String transcriptTail;
  final int turnCount;

  /// R9.a — escalation guidance carried by the latest turn (null when the
  /// last turn was not guided).
  final String? lastGuidance;

  /// ADR 0007 — the roster (one state, many projections, DESIGN §5): the
  /// agent reads the same actor identities the PROFILE pane renders.
  final List<ActorProfile> actors;

  /// ADR 0006 registry `Actors[]`: session view id → attached actor ids.
  final Map<String, List<String>> sessionActors;

  /// PLAN 5c — remote permission records announced by OTHER peers
  /// (pending and answered): the same doc state the peer's flow renders
  /// (one state, many projections, DESIGN §5) — an agent reads who is
  /// asking, from where, and what has been decided.
  final List<PermRequestRecord> remotePermissions;

  /// Task H — whether remote permission routing is enabled (the PROFILE
  /// toggle's state, projected for the agent — DESIGN §5).
  final bool remotePermissionRouting;

  /// Task H — the mesh status of this device relative to the open doc:
  /// hosting / connected / peer count / presence count. Null when the app
  /// wiring is not installed (mesh never set up) — an agent reads the
  /// same status rule data the human sees (DESIGN §5/§9).
  final AgentDocMeshStatus? meshStatus;

  /// PLAN 9 — the queue state (ADR 0011): every step — open (with lane
  /// position + age), superseded (cancelled, queryable), delivered — the
  /// same queue the grid renders (DESIGN §5: one state, many projections).
  final List<AgentDocQueueEntry> queue;

  /// PLAN 6.C — the mesh task console records for this doc (the shared
  /// CRDT task board row shape): dispatches, runs, and verdicts — the
  /// gate/agent-readable surface. Empty when no board is attached on this
  /// device.
  final List<Map<String, Object?>> tasks;

  /// Task O — the honest viewer marker (DESIGN §6: label what the host
  /// sees vs what the peer observes). False on the host (it owns the
  /// world); true on a peer's SHADOW doc (`mesh_open_doc`): the peer
  /// observes the shared doc and answers routed permissions — it binds no
  /// workspace and runs no daemon session.
  final bool viewer;
  final Map<String, Object?>? meaning;

  Map<String, Object?> toJson() => {
    'docId': docId,
    'workspaces': workspaces,
    'checkCommand': checkCommand,
    'backend': backend,
    'runtimeProfile': runtimeProfile,
    'sessionId': ?sessionId,
    'running': running,
    'pendingPermissionTitle': ?pendingPermissionTitle,
    'verdict': ?verdict,
    'turnCount': turnCount,
    'lastGuidance': ?lastGuidance,
    'actors': [for (final a in actors) a.toJson()],
    'sessionActors': sessionActors,
    'remotePermissions': [for (final p in remotePermissions) p.toJson()],
    'remotePermissionRouting': remotePermissionRouting,
    if (meshStatus != null) 'meshStatus': meshStatus!.toJson(),
    'queue': [for (final q in queue) q.toJson()],
    'tasks': tasks,
    'viewer': viewer,
    'meaning': ?meaning,
    'transcriptTail': transcriptTail.length > 4000
        ? '${transcriptTail.substring(0, 4000)}…'
        : transcriptTail,
  };
}

/// PLAN 9 — one queue step in the projection: lane key `(from, to)`
/// (ADR 0011 D5), step status (`open | superseded | delivered`), the
/// claim text, and — for open steps — the 1-based position in the lane
/// and the age (DESIGN §10: time made visible).
final class AgentDocQueueEntry {
  const AgentDocQueueEntry({
    required this.id,
    required this.text,
    required this.status,
    required this.from,
    required this.to,
    required this.immediate,
    required this.createdAtMs,
    this.position,
    this.ageMs,
  });

  final String id;
  final String text;
  final String status;
  final String from;
  final String to;
  final bool immediate;
  final int createdAtMs;

  /// 1-based position among the lane's open steps; null when superseded
  /// or delivered (no longer in the rendered queue).
  final int? position;
  final int? ageMs;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'status': status,
    'from': from,
    'to': to,
    'immediate': immediate,
    'createdAtMs': createdAtMs,
    'position': ?position,
    'ageMs': ?ageMs,
  };
}

/// Task H — the mesh status of THIS device relative to one doc's channel
/// (what the status rule reports, DESIGN §9: connection truth in tabular
/// mono). Honest by construction: every value is read from the live mesh
/// replica; when the replica is not open, the wiring reports the zeros.
final class AgentDocMeshStatus {
  const AgentDocMeshStatus({
    this.hosting = false,
    this.connected = false,
    this.peerCount = 0,
    this.presenceCount = 0,
  });

  /// Whether this device hosts the relay ("main device").
  final bool hosting;

  /// Whether the replica has a transport connected.
  final bool connected;

  /// Registered peers on the replica.
  final int peerCount;

  /// Live presence entries on the doc's channel ("who is here" right
  /// now — the mesh service's presence).
  final int presenceCount;

  Map<String, Object?> toJson() => {
    'hosting': hosting,
    'connected': connected,
    'peerCount': peerCount,
    'presenceCount': presenceCount,
  };
}
