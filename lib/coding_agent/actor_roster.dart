/// ADR 0007 — the actor roster: stable, user-scoped, shareable actor
/// identities.
///
/// A device hosts several actors (a model, an agent runtime, the human);
/// the same identities recur across days and devices. The roster gives
/// them user-facing identity: [ActorProfile] — who (`actorId`, stable
/// across sessions and devices), what kind, which brain, what role.
///
/// Sync: the roster IS a kernel document — a `ConvergenceDoc` (LWW map,
/// ADR 0011) keyed `actor/<actorId>`. Local-first edits are ordinary
/// kernel ops; durable JSON persistence round-trips through
/// [toJson]/[fromJson]. The mesh layer attaches to the exposed seams
/// ([pendingOps], [applyRemote], [versionVector], [opsSince],
/// [snapshotFor]/[adoptSnapshot]) WITHOUT an API change — no sync wiring
/// is built here (ADR 0007 Phase 5 gate).
///
/// Identity layering (ADR 0007 §2): an actor is live ON a peer; presence
/// keys are `(peerId, actorId)`. The roster is the dedupe key, never the
/// location, and never grants authority (§3).
library;

import 'package:flutter/foundation.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

/// What holds the agency (ADR 0003 vocabulary, ADR 0007 §1).
enum ActorKind { model, agent, human }

String _actorKindToJson(final ActorKind kind) => switch (kind) {
  ActorKind.model => 'model',
  ActorKind.agent => 'agent',
  ActorKind.human => 'human',
};

ActorKind _actorKindFromJson(final String raw) => switch (raw) {
  'model' => ActorKind.model,
  'agent' => ActorKind.agent,
  'human' => ActorKind.human,
  _ => throw ArgumentError.value(raw, 'kind', 'Unknown actor kind'),
};

/// Tolerant read-side twin of [_actorKindFromJson]: null for anything
/// that is not a known kind — callers decide whether to discard or
/// default. Unknown kinds from a newer replica are discarded, never
/// guessed (DESIGN §6).
ActorKind? _actorKindFromJsonOrNull(final Object? raw) => switch (raw) {
  'model' => ActorKind.model,
  'agent' => ActorKind.agent,
  'human' => ActorKind.human,
  _ => null,
};

/// One actor identity: a model with a role, an agent runtime, a human.
/// Immutable data (ADR 0003: actors are data; brains are data) — profiles
/// are values; editing one means upserting a new one over the same
/// [actorId].
@immutable
@immutable
final class ActorProfile {
  const ActorProfile({
    required this.actorId,
    required this.displayName,
    this.kind = ActorKind.model,
    this.brainRef = '',
    this.role = '',
  }) : assert(actorId.length > 0, 'actorId is required'),
       assert(displayName.length > 0, 'displayName is required');

  factory ActorProfile.fromJson(final Map<String, dynamic> json) =>
      ActorProfile(
        actorId: json['actorId'] as String,
        displayName: json['displayName'] as String,
        kind: _actorKindFromJson(json['kind'] as String? ?? 'model'),
        brainRef: json['brainRef'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );

  /// Stable across devices and sessions (ADR 0007 §1) — the roster key
  /// and the presence dedupe key (§2). Not the peer: peers authenticate
  /// devices; actors ride payloads.
  final String actorId;

  /// What the human sees; the source of the gutter label.
  final String displayName;

  final ActorKind kind;

  /// Backend/model identity (ADR 0003: the brain is data, not code).
  final String brainRef;

  /// What the actor is for, in the user's words ('coder', 'reviewer'…).
  final String role;

  Map<String, Object?> toJson() => {
    'actorId': actorId,
    'displayName': displayName,
    'kind': _actorKindToJson(kind),
    'brainRef': brainRef,
    'role': role,
  };

  /// DESIGN §9 — this actor's role-gutter label: the small-caps
  /// vocabulary (`YOU`, `AFM`, `OR`, `SYS`, `PERM`) extended with actor
  /// names (`AFM-CODER`, `PI`). Same size, same tracking, no avatars.
  /// The human's own label stays `YOU` (ADR 0007 §4) — the surface
  /// decides; this helper only renders the name.
  String get gutterLabel => actorGutterLabel(displayName);

  @override
  bool operator ==(final Object other) =>
      other is ActorProfile &&
      other.actorId == actorId &&
      other.displayName == displayName &&
      other.kind == kind &&
      other.brainRef == brainRef &&
      other.role == role;

  @override
  int get hashCode => Object.hash(actorId, displayName, kind, brainRef, role);

  @override
  String toString() =>
      'ActorProfile($actorId, $displayName, ${_actorKindToJson(kind)}, '
      'brain: $brainRef, role: $role)';
}

/// Resolves an actor's display name into a gutter label (DESIGN §9):
/// alphanumeric words, dash-joined, small-caps by the label style,
/// capped to the gutter's readable width at a word boundary (`afm coder`
/// → `AFM-CODER`; `apple foundation model` → `APPLE`; a single
/// over-long word is hard-capped). Empty names render `ACTOR` — honest
/// absence, never a blank gutter cell.
String actorGutterLabel(final String displayName) {
  final words = RegExp('[a-zA-Z0-9]+')
      .allMatches(displayName)
      .map((final m) => m.group(0)!.toUpperCase())
      .toList();
  if (words.isEmpty) return 'ACTOR';
  const cap = 12;
  var label = words.first;
  for (var i = 1; i < words.length; i++) {
    final candidate = '$label-${words[i]}';
    if (candidate.length > cap) break;
    label = candidate;
  }
  return label.length > cap ? label.substring(0, cap) : label;
}

/// The actor roster: ordinary durable kernel state (ADR 0007 §1) — an
/// LWW [ConvergenceDoc] whose keys are `actor/<actorId>` entries. Roster
/// edits are local-first ops; replicas converge by the kernel's
/// guarantees (no roster merge UI, v1). No account, no server.
final class ActorRoster {
  ActorRoster({required final String replicaId, this.docId = defaultDocId})
    : _doc = ConvergenceDoc(docId: docId, actorId: replicaId);

  factory ActorRoster.fromJson(final Map<String, dynamic> json) =>
      ActorRoster._(ConvergenceDoc.fromJson(json));

  ActorRoster._(final ConvergenceDoc doc)
    : docId = doc.docId,
      _doc = doc;

  /// The kernel document id. One roster per user scope; entries are the
  /// `actor/` namespace inside it.
  static const defaultDocId = 'actor_roster';

  /// Key namespace inside the doc (ADR 0007 §1: keyed `actor/<actorId>`).
  static const keyPrefix = 'actor/';

  final String docId;

  ConvergenceDoc _doc;

  String get replicaId => _doc.actorId;

  /// Mesh plumbing (ADR 0007 §2, PLAN 5c): forces the replica id — the
  /// kernel actor id every local op carries — to the pairing peer id of
  /// the attaching [MeshStorageService]. Rosters are often built with a
  /// placeholder id before the mesh layer exists; the service replaces it
  /// at attach time by re-deriving the doc from the same durable op log
  /// under the forced id (ops are the source of truth; the kernel's VV
  /// dedupe keeps re-application safe, and delivery order never affects
  /// the fold).
  void forceReplicaId(final String replicaId) {
    if (_doc.actorId == replicaId) return;
    final ops = _doc.pendingOps;
    _doc = ConvergenceDoc(docId: docId, actorId: replicaId)
      ..applyRemote(ops);
  }

  static String _key(final String actorId) => '$keyPrefix$actorId';

  /// Resolves [actorId]; null when unknown or removed (tombstoned). An
  /// entry whose value is not a well-formed profile reads as absent — a
  /// malformed remote payload must not take the pane down; the offending
  /// op stays in the doc for inspection.
  ActorProfile? get(final String actorId) {
    if (actorId.isEmpty) return null;
    final entry = _doc.state[_key(actorId)];
    if (entry is! Map || entry['del'] == true) return null;
    final value = entry['v'];
    if (value is! Map) return null;
    final id = value['actorId'];
    final name = value['displayName'];
    if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
      return null;
    }
    final kind = _actorKindFromJsonOrNull(value['kind']);
    if (value['kind'] != null && kind == null) return null;
    return ActorProfile(
      actorId: id,
      displayName: name,
      kind: kind ?? ActorKind.model,
      brainRef: value['brainRef'] is String ? value['brainRef'] as String : '',
      role: value['role'] is String ? value['role'] as String : '',
    );
  }

  /// All live profiles, deterministic order (name, then id) — small
  /// multiples render identically on every replica.
  List<ActorProfile> get all {
    final profiles = <ActorProfile>[
      for (final actorId in _liveIds()) ?get(actorId),
    ]..sort((final a, final b) {
      final byName = a.displayName.toLowerCase().compareTo(
        b.displayName.toLowerCase(),
      );
      return byName != 0 ? byName : a.actorId.compareTo(b.actorId);
    });
    return profiles;
  }

  Iterable<String> _liveIds() sync* {
    for (final key in _doc.state.keys) {
      if (key.startsWith(keyPrefix)) {
        final entry = _doc.state[key];
        if (entry is Map && entry['del'] != true) {
          yield key.substring(keyPrefix.length);
        }
      }
    }
  }

  int get length => _liveIds().length;
  bool get isEmpty => length == 0;
  bool get isNotEmpty => length > 0;
  bool contains(final String actorId) => get(actorId) != null;

  /// Inserts or updates [profile] (ordinary local-first edit — an LWW
  /// op). Validated: ids and names are non-empty.
  ActorProfile upsert(
    final ActorProfile profile, {
    final DateTime? now,
  }) {
    final actorId = profile.actorId.trim();
    final displayName = profile.displayName.trim();
    if (actorId.isEmpty) {
      throw ArgumentError.value(profile, 'profile', 'actorId is required');
    }
    if (displayName.isEmpty) {
      throw ArgumentError.value(profile, 'profile', 'displayName is required');
    }
    _doc.applyLocal(
      {
        'k': _key(actorId),
        'v': ActorProfile(
          actorId: actorId,
          displayName: displayName,
          kind: profile.kind,
          brainRef: profile.brainRef.trim(),
          role: profile.role.trim(),
        ).toJson(),
      },
      now ?? DateTime.now(),
    );
    return profile;
  }

  /// Tombstones [actorId] (deletes propagate — the kernel keeps the
  /// tombstone winning). Returns false when the actor was not live.
  bool remove(final String actorId, {final DateTime? now}) {
    if (!contains(actorId)) return false;
    _doc.applyLocal({'k': _key(actorId), 'del': true}, now ?? DateTime.now());
    return true;
  }

  /// Deterministic new id for an in-flow add: a slug of the display name,
  /// de-duplicated against live entries (`afm-coder`, `afm-coder-2`, …).
  String newActorId(final String displayName) {
    final slug = displayName
        .toLowerCase()
        .split(RegExp('[^a-z0-9]+'))
        .where((final w) => w.isNotEmpty)
        .join('-');
    var base = slug.isEmpty ? 'actor' : slug;
    if (base.length > 24) base = base.substring(0, 24);
    if (!contains(base)) return base;
    var n = 2;
    while (contains('$base-$n')) {
      n++;
    }
    return '$base-$n';
  }

  // -- Sync seams (the mesh layer attaches here; nothing is wired yet —
  //    ADR 0007 Phase 5 gate: store the seams, don't build them). ------

  /// Durable ops not yet compacted — the delta a lagging replica needs.
  List<OpRecord> get pendingOps => _doc.pendingOps;

  /// The durable version vector (per-actor high-water marks of applied
  /// ops).
  VersionVector get versionVector => _doc.vv;

  /// Ops this replica holds that [remoteVv] has not observed.
  List<OpRecord> opsSince(final VersionVector remoteVv) =>
      _doc.opsSince(remoteVv);

  /// Folds remote ops (idempotent, order-free — kernel contract). Returns
  /// how many were newly applied.
  int applyRemote(final Iterable<OpRecord> ops, {final DateTime? now}) =>
      _doc.applyRemote(ops, now: now);

  /// True when [remoteVv] is covered but content is missing (our log was
  /// compacted) — ship a snapshot instead.
  bool needsSnapshotFor(final VersionVector remoteVv) =>
      _doc.needsSnapshotFor(remoteVv);

  Snapshot snapshotFor() => _doc.snapshotFor();

  bool adoptSnapshot(final Snapshot snapshot) => _doc.adoptSnapshot(snapshot);

  /// Full serialization for durable local persistence (JSON round-trip;
  /// the restored roster keeps its monotonic HLC watermark).
  Map<String, dynamic> toJson() => _doc.toJson();
}
