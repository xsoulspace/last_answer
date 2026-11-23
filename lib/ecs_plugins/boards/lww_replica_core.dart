/// The shared LWW replica core under the boards program: the ONE home of
/// the key/HLC-clock/absorb machinery that `MeshTaskBoard` and
/// `PlanningBoardReplica` both ride (the boards-extraction program,
/// docs/design/ecsly-boards-extraction.md §4 stages 2/3 — the storage
/// slice). Previously the two replicas carried this machinery nearly
/// line-for-line; both are now re-based onto this core with their public
/// APIs and wire formats unchanged.
///
/// One replica = ONE [WorldSync] replica (kernel `ConvergenceDoc`, LWW
/// map, ADR 0011) whose doc id is the replica's board id. Every content
/// field is one keyed register, written through `WorldSync.applyDelta`
/// (one op per field change — a status change writes ONLY the status
/// field):
///
/// - entity key: `<entityPrefix><docId>/<localId>`, component
///   [component];
/// - the full sync key is
///   `<entityPrefix><docId>/<localId>/<component>/<field>`.
///
/// Reads go through `WorldSync.projection` (values are JSON-encoded
/// strings — decoded by the projection, grouped per entity by
/// [foldEntityFields]).
///
/// Register rows are immutable data: replicas converge per FIELD by the
/// kernel's LWW, so a concurrent write pair lands on the highest HLC
/// everywhere — there is no lifecycle enforcement, only
/// last-writer-wins registers (callers gate).
///
/// Compound ids: `<docId>#<localId>`. `localId` is HLC-derived from a
/// board-level own-actor clock ([newLocalId], one [Hlc.tick] per
/// create): unique per board (strictly monotonic, even on a frozen wall
/// clock), unique across boards (the actor id is embedded),
/// deterministic, and monotonic across restarts (persisted under
/// `toJson`'s `issued_clock` key). Doc ids must not contain `#`
/// (compound ids split at the LAST `#`).
///
/// HLC receive-watermark floor: `WorldSync` folds ops and adopts
/// snapshots but never ticks on receive (`ConvergenceDoc` has no
/// `lastIssued` passthrough in `applyDelta`, and `adoptSnapshot` does not
/// absorb `snapshot.createdAt`) — unlike `DocReplica`, which maintains a
/// receive watermark via the kernel's `lastIssued` seam. The gap: a local
/// write issued after folding a remote op with an ahead wall clock would
/// carry a LOWER HLC and lose LWW to the causally-older remote write.
/// This core closes the gap itself (the ecsly repo is not patched): it
/// keeps the high-water HLC of everything received (remote ops in
/// [applyRemote], `snapshot.createdAt` in [adoptSnapshot], the restored
/// log in [absorbRestoredFile]) and floors the `now` handed to
/// `applyDelta` strictly above that watermark's wall clock ([issueTime];
/// `Hlc.tick` is monotonic in `max(now, previous)`, so a wall clock
/// strictly above every received op's wall wins regardless of counters).
/// Persisted under `received_clock`.
library;

import 'package:ecsly_world_sync/ecsly_world_sync.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

/// The replica machinery shared by every board over [WorldSync]: kernel
/// doc keying, the HLC clocks (task-id monotonicity + the receive
/// floor), the whole sync seam set (ops/snapshot exchange, compaction,
/// the durable `toJson`/restore discipline), and the keyed-register
/// read/write paths.
///
/// Subclass contract (what a concrete replica adds): its namespace
/// ([entityPrefix]/[component]), its record projection over
/// [foldEntityFields], its deterministic sort, and its domain verbs —
/// each verb issuing one op per changed field through [write] at
/// [issueTime], with ids from [newLocalId].
abstract base class LwwReplicaCore {
  /// Creates a replica owned by [replicaId] (the mesh peer id) whose
  /// kernel doc id is [boardId]: ops and snapshots are docId-scoped by
  /// the kernel, so replicas of one board converge and replicas of
  /// different boards never mix.
  LwwReplicaCore({
    required final String replicaId,
    required final String boardId,
    final DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _sync = WorldSync(actorId: replicaId, docId: boardId);

  /// Restore seam for the replicas' `fromJson` factories: adopts an
  /// already-restored [WorldSync] kernel. Not for direct consumer use —
  /// the replicas' factories pair this with [restoredWorldOf] and
  /// [absorbRestoredFile] to keep the proven restore order in one place.
  LwwReplicaCore.restored(
    final WorldSync sync, {
    final DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _sync = sync;

  final WorldSync _sync;
  final DateTime Function() _now;

  /// Highest HLC this replica has causally RECEIVED (remote ops, adopted
  /// snapshots, restored log) — the receive-watermark floor. The actor is
  /// kept verbatim: this watermark is only ever read for its wall clock
  /// ([issueTime]), never issued from.
  Hlc? _receivedWatermark;

  /// This replica's own-actor HLC, ticked per entity creation
  /// ([newLocalId]). Never absorbs a foreign actor.
  Hlc? _issuedClock;

  /// Snapshot most recently taken or adopted — persisted under the
  /// `snapshot` key so restores keep serving lagging peers across
  /// restarts (the `DocReplica` durable-cache discipline; for a
  /// COMPACTED file the snapshot is the only state carrier).
  Snapshot? _lastSnapshot;

  /// The board id (the kernel doc id).
  String get boardId => _sync.docId;

  /// The mesh peer id owning this replica.
  String get replicaId => _sync.actorId;

  // ---------------------------------------------------------------------------
  // Namespace contract (subclass seams)
  // ---------------------------------------------------------------------------

  /// The entity-key namespace prefix, e.g. `'task/'` or `'card/'`.
  String get entityPrefix;

  /// The component name riding every sync key of this replica.
  String get component;

  // ---------------------------------------------------------------------------
  // Restore (the shared durable-file discipline)
  // ---------------------------------------------------------------------------

  /// Restores the kernel replica from a persisted file's `world` entry
  /// and refuses a mismatched envelope `board_id` (the shared `fromJson`
  /// contract — same errors and messages for every replica). The replica
  /// factories then build themselves on the result and finish with
  /// [absorbRestoredFile].
  static WorldSync restoredWorldOf(final Map<String, Object?> json) {
    final worldJson = json['world'];
    if (worldJson is! Map) {
      throw ArgumentError.value(json, 'json', 'missing world state');
    }
    final sync = WorldSync.fromJson(Map<String, dynamic>.from(worldJson));
    final boardId = json['board_id'];
    if (boardId is String && boardId != sync.docId) {
      throw ArgumentError.value(
        boardId,
        'board_id',
        'does not match the kernel doc id ${sync.docId}',
      );
    }
    return sync;
  }

  /// Completes a [restoredWorldOf] restore — the proven `DocReplica`
  /// order, raise-only throughout:
  ///
  /// 1. The `snapshot` entry (when present) is adopted via
  ///    [adoptSnapshot]. The kernel adopts only snapshots carrying events
  ///    the restored doc has not seen (VERIFIED against the kernel
  ///    source: `ConvergenceDoc.fromJson` does NOT re-fold the log — the
  ///    folded `state` is restored as-is, authoritative; the `log` is
  ///    restored purely for delta shipping). For a self-consistent file
  ///    this merely re-arms the snapshot cache (and the HLC floor); for a
  ///    compacted file the snapshot IS the state carrier and this is
  ///    what recovers the entities.
  /// 2. Clocks are recomputed raise-only: `issued_clock` (local-id
  ///    monotonicity), `received_clock` (LWW causality floor), every op
  ///    in the restored log, and the adopted snapshot's `createdAt` — a
  ///    restore never lowers a watermark past the file's own content.
  void absorbRestoredFile(final Map<String, Object?> json) {
    final snapshotJson = json['snapshot'];
    if (snapshotJson is Map) {
      adoptSnapshot(
        Snapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
      );
    }
    final issued = _hlcOf(json['issued_clock']);
    if (issued != null) _raiseIssued(issued);
    final received = _hlcOf(json['received_clock']);
    if (received != null) _absorbReceived(received);
    for (final op in _sync.pendingOps) {
      _absorbReceived(op.hlc);
      if (op.actorId == replicaId) _raiseIssued(op.hlc);
    }
  }

  // ---------------------------------------------------------------------------
  // Keys (compound ids and the sync-key grammar)
  // ---------------------------------------------------------------------------

  /// Splits `<docId>#<localId>` at the LAST `#` (doc ids must not
  /// contain `#`); null when malformed.
  static (String, String)? splitCompoundId(final String id) {
    final hash = id.lastIndexOf('#');
    if (hash <= 0 || hash == id.length - 1) return null;
    return (id.substring(0, hash), id.substring(hash + 1));
  }

  /// The sync entity key `<entityPrefix><docId>/<localId>` (the full
  /// sync key is `<entity>/<component>/<field>`).
  String entityKey(final String docId, final String localId) =>
      '$entityPrefix$docId/$localId';

  /// Parses a sync key
  /// `<entityPrefix><docId>/<localId>/<component>/<field>`. The
  /// doc/local split sits at the last `/` of the entity part, so doc ids
  /// may contain `/` but local ids may not. Null when the key belongs to
  /// another namespace or is malformed.
  (String, String, String)? parseEntityKey(final String key) {
    if (!key.startsWith(entityPrefix)) return null;
    final rest = key.substring(entityPrefix.length);
    final componentSeparator = '/$component/';
    final componentStart = rest.lastIndexOf(componentSeparator);
    if (componentStart < 0) return null;
    final field = rest.substring(componentStart + componentSeparator.length);
    final entity = rest.substring(0, componentStart);
    final slash = entity.lastIndexOf('/');
    if (slash <= 0 || slash == entity.length - 1) return null;
    return (entity.substring(0, slash), entity.substring(slash + 1), field);
  }

  /// Folds the projection's keyed registers into per-entity field maps,
  /// keyed `<docId>#<localId>`; keys outside this replica's namespace
  /// and null registers are skipped. The one read path every replica
  /// projects its records from.
  Map<String, Map<String, Object?>> foldEntityFields() {
    final fieldsByEntity = <String, Map<String, Object?>>{};
    _sync.projection.values.forEach((final key, final value) {
      final parsed = parseEntityKey(key);
      if (parsed == null || value == null) return;
      final (docId, localId, field) = parsed;
      fieldsByEntity
          .putIfAbsent('$docId#$localId', () => <String, Object?>{})[field] =
          value;
    });
    return fieldsByEntity;
  }

  // ---------------------------------------------------------------------------
  // Writes (one op per field change)
  // ---------------------------------------------------------------------------

  /// Writes one LWW register through `WorldSync.applyDelta` at [at] —
  /// the replica verbs' only write path (a status change writes ONLY the
  /// status field).
  void write(
    final String docId,
    final String localId,
    final String field,
    final Object? value,
    final DateTime at,
  ) {
    _sync.applyDelta(
      ComponentDelta(
        entityKey: entityKey(docId, localId),
        component: component,
        field: field,
        value: value,
      ),
      at,
    );
  }

  // ---------------------------------------------------------------------------
  // Clocks (local-id monotonicity + the HLC receive floor)
  // ---------------------------------------------------------------------------

  /// The wall clock handed to `applyDelta`, floored strictly above every
  /// received op's wall clock. `Hlc.tick` is monotonic in
  /// `max(now, previous)`, so the issued op's HLC lands strictly above
  /// the whole received history — the causality the kernel's `applyLocal`
  /// cannot see (it only tracks this replica's own entry).
  DateTime issueTime(final DateTime? now) {
    final real = (now ?? _now()).millisecondsSinceEpoch;
    final watermark = _receivedWatermark;
    if (watermark != null && real <= watermark.wallMillis) {
      return DateTime.fromMillisecondsSinceEpoch(watermark.wallMillis + 1);
    }
    return DateTime.fromMillisecondsSinceEpoch(real);
  }

  /// Next HLC-derived local id (`wall:counter:actor`): strictly
  /// monotonic per board even on a frozen wall clock.
  String newLocalId(final DateTime at) {
    final current = _issuedClock ?? Hlc.zero(replicaId);
    final next = current.tick(at);
    _issuedClock = next;
    return '${next.wallMillis}:${next.counter}:${next.actorId}';
  }

  void _raiseIssued(final Hlc hlc) {
    final current = _issuedClock;
    if (current != null && current >= hlc) return;
    _issuedClock = hlc;
  }

  void _absorbReceived(final Hlc remote) {
    final current = _receivedWatermark;
    if (current != null && current >= remote) return;
    _receivedWatermark = remote;
  }

  static Hlc? _hlcOf(final Object? raw) =>
      raw is Map ? Hlc.fromJson(Map<String, dynamic>.from(raw)) : null;

  // ---------------------------------------------------------------------------
  // Sync seams (kernel-backed via WorldSync)
  // ---------------------------------------------------------------------------

  /// The replica's current version vector.
  VersionVector get versionVector => _sync.vv;

  /// Ops this replica holds that [remoteVv] has not observed.
  List<OpRecord> opsSince(final VersionVector remoteVv) =>
      _sync.opsFor(remoteVv);

  /// Folds remote ops (idempotent, order-free — kernel contract) and
  /// raises the receive-watermark floor above every delivered op so later
  /// local writes win LWW over what they causally follow. Returns how
  /// many ops were newly applied.
  int applyRemote(final Iterable<OpRecord> ops) {
    final applied = _sync.applyRemote(ops);
    if (applied > 0) {
      for (final op in ops) {
        _absorbReceived(op.hlc);
      }
    }
    return applied;
  }

  /// True when [remoteVv] is fully covered but this replica's log was
  /// compacted — the caller must ship [snapshotFor] instead.
  bool needsSnapshotFor(final VersionVector remoteVv) =>
      _sync.needsSnapshotFor(remoteVv);

  /// The current state as a snapshot at this replica's watermark;
  /// remembered for [toJson] (the durable snapshot cache).
  Snapshot snapshotFor() {
    final snapshot = _sync.snapshotFor();
    _lastSnapshot = snapshot;
    return snapshot;
  }

  /// Adopts [snapshot] when it carries unseen events (safe and idempotent
  /// per the kernel contract); local pending ops beyond the snapshot base
  /// are kept and re-folded by the kernel. The snapshot's `createdAt` is
  /// absorbed into the HLC floor so later local writes order after the
  /// snapshot content. The offered snapshot is remembered for [toJson]
  /// even when refused (refusal proves full coverage — the `DocReplica`
  /// discipline).
  bool adoptSnapshot(final Snapshot snapshot) {
    final adopted = _sync.adoptSnapshot(snapshot);
    _lastSnapshot = snapshot;
    if (!adopted) return false;
    _absorbReceived(snapshot.createdAt);
    return true;
  }

  /// Compacts when the WorldSync log exceeds [maxLogOps]: the current
  /// state becomes the snapshot and the log is truncated (the periodic
  /// policy — cheap, fires only above the threshold). Returns 1 when
  /// compacted, else 0.
  int compact({final int maxLogOps = 512}) {
    if (_sync.pendingOps.length <= maxLogOps) return 0;
    _sync.compact();
    _lastSnapshot = _sync.snapshotFor();
    return 1;
  }

  /// Full durable op log (for the whole-file flush/absorb exchange).
  List<OpRecord> get pendingOps => _sync.pendingOps;

  /// Full serialization for durable local persistence: the WorldSync
  /// state, the snapshot cache when one was taken/adopted, board
  /// metadata, and both HLC clocks (local-id monotonicity + receive
  /// floor).
  Map<String, Object?> toJson() => {
    'board_id': boardId,
    'replica_id': replicaId,
    'world': _sync.toJson(),
    if (_lastSnapshot != null) 'snapshot': _lastSnapshot!.toJson(),
    if (_issuedClock != null) 'issued_clock': _issuedClock!.toJson(),
    if (_receivedWatermark != null)
      'received_clock': _receivedWatermark!.toJson(),
  };

  /// Rewrites a board file between replica doc ids in place (ADR 0028).
  ///
  /// The replica doc id rides flat `doc_id` fields at every level of the
  /// persisted shape — each log op ([OpRecord.toJson], where the op id is
  /// derived as `docId#hlc#wall#counter#actor`), the adopted snapshot, the
  /// convergence doc — plus the envelope's `board_id`. The kernel drops
  /// ops whose `doc_id` differs from the replica's own, so a file must be
  /// rewritten BEFORE it folds; entity keys are untouched (they embed the
  /// record's own document id, which is independent of the board id).
  /// Only exact-match values on the two known keys are rewritten, and the
  /// rewrite is idempotent under the version vector — re-absorbing the
  /// same file folds nothing new.
  static Map<Object?, Object?> rekeyDocId(
    final Map<Object?, Object?> json, {
    required final String from,
    required final String to,
  }) {
    if (from == to) return json;
    void walk(final Object? node) {
      if (node is Map) {
        node.forEach((final key, final value) {
          if ((key == 'board_id' || key == 'doc_id') && value == from) {
            node[key] = to;
          } else {
            walk(value);
          }
        });
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(json);
    return json;
  }
}
