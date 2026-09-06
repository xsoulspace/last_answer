import 'dart:convert';

import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

import 'doc_replica.dart';
import 'document_node.dart';

/// Durable home for [DocReplica]s over any [StorageService] (ADR 0005 §1:
/// docs are event-sourced over the kernel — this store persists and ships
/// kernel ops; it never merges by hand).
///
/// Layout: one JSON file per document under `<dir>/<docId>.json`, written
/// through `DocReplica.toJson` / restored through `DocReplica.fromJson`.
///
/// Persistence is BATCHED, never per op: local ops issued through [edit]
/// and remote ops folded through [applyRemote] only mark the replica
/// dirty; [flush] writes every dirty replica (one file per doc). The mesh
/// sync cycle ([MeshStorageService.attachDocSync]) flushes before
/// anti-entropy; [dispose] flushes too.
///
/// Op-exchange seams (per doc): [versionVectorOf] + [pendingOpsSince]
/// produce the delta for a remote store ([pendingOpsSince] is the kernel's
/// VV diff); [applyRemote] folds a remote delta (idempotent and
/// delivery-order independent per the kernel contract). [absorbRemote]
/// re-reads the persisted replica files — after a mesh anti-entropy cycle
/// they may contain a peer's replica JSON — and folds any ops the local
/// replicas have not seen.
///
/// File-actor honesty: the per-doc file holds WHOEVER flushed last, so
/// [open] only fast-paths `DocReplica.fromJson` when the file's
/// `actor_id` matches this store's actor; otherwise the replica is born
/// with THIS store's actor id and the file's durable op log is folded in
/// through the kernel (ops are the source of truth; the kernel's VV dedupe
/// makes re-application safe). Whole-file mesh sync is LWW per file: a
/// peer's flush can temporarily shadow local ops, but the local replica
/// still holds them and the next [flush] writes the merged log —
/// replicas converge because every store folds the union of ops.
final class DocReplicaStore {
  DocReplicaStore({
    required this._storage,
    required this.actorId,
    this.dir = 'doc_replicas',
  });

  final StorageService _storage;

  /// Actor id every local op issued by this store's replicas carries.
  final String actorId;

  /// Directory under storage holding one file per document.
  final String dir;

  final Map<String, DocReplica> _replicas = {};
  final Set<String> _dirty = {};

  String _path(final NodeId docId) => '$dir/${docId.value}.json';

  /// Opens (loads or births) the replica for [docId]. Idempotent: the
  /// already-opened replica is returned unchanged.
  ///
  /// Loading restores through `DocReplica.fromJson` when the persisted
  /// file was written by this store's actor; a file written by a peer is
  /// re-derived by folding its op log into a fresh local replica (see the
  /// file-actor note in the class doc).
  Future<DocReplica> open(final NodeId docId) async {
    final existing = _replicas[docId.value];
    if (existing != null) return existing;
    final raw = await _storage.readFile(_path(docId));
    final replica = raw == null
        ? DocReplica(nodeId: docId, actorId: actorId)
        : _restore(docId, raw);
    _replicas[docId.value] = replica;
    return replica;
  }

  /// The opened replica for [docId], or null when never opened.
  DocReplica? replicaOf(final NodeId docId) => _replicas[docId.value];

  /// Runs a local edit against the opened replica for [docId] and returns
  /// the issued ops. The replica is marked dirty; persistence happens in
  /// [flush] (batched — this never writes per op).
  Future<List<OpRecord>> edit(
    final NodeId docId,
    final List<OpRecord> Function(DocReplica replica) action,
  ) async {
    final replica = await open(docId);
    final ops = action(replica);
    if (ops.isNotEmpty) _dirty.add(docId.value);
    return ops;
  }

  /// THIS replica's version vector for [docId] — the anti-entropy header
  /// a remote store diffs against with [pendingOpsSince]. Null when the
  /// doc was never opened.
  VersionVector? versionVectorOf(final NodeId docId) =>
      _replicas[docId.value]?.versionVector;

  /// Ops this store holds that [remoteVv] has not observed (VV diff →
  /// ops). Empty when the doc was never opened.
  List<OpRecord> pendingOpsSince(
    final NodeId docId,
    final VersionVector remoteVv,
  ) => _replicas[docId.value]?.pendingOpsSince(remoteVv) ?? const [];

  /// Folds [ops] into the opened replica for [docId] (creating it when
  /// needed) and marks it dirty for the next [flush]. Idempotent and
  /// delivery-order independent per the kernel contract. Returns how many
  /// ops were newly applied.
  Future<int> applyRemote(
    final NodeId docId,
    final Iterable<OpRecord> ops,
  ) async {
    final replica = await open(docId);
    final applied = replica.applyRemote(ops);
    if (applied > 0) _dirty.add(docId.value);
    return applied;
  }

  /// Re-reads every persisted replica file under [dir] and folds ops the
  /// local replicas have not seen (kernel VV dedupe makes this
  /// idempotent). Call after a mesh anti-entropy cycle: the files may now
  /// carry a peer's replica JSON. Files for docs this store never opened
  /// are skipped — the app opens the docs it renders, and [open] derives
  /// a peer-written file on first open. Returns how many ops were newly
  /// applied in total.
  Future<int> absorbRemote() async {
    final entries = await _storage.listDirectory(dir);
    var applied = 0;
    for (final entry in entries) {
      if (entry.isDirectory || !entry.name.endsWith('.json')) continue;
      final docId = entry.name.substring(0, entry.name.length - 5);
      final replica = _replicas[docId];
      if (replica == null) continue; // Not a doc this store tracks.
      final raw = await _storage.readFile('$dir/${entry.name}');
      if (raw == null) continue;
      final n = replica.applyRemote(_opsOf(raw));
      if (n > 0) {
        applied += n;
        _dirty.add(docId);
      }
    }
    return applied;
  }

  /// Writes every dirty replica — one file per doc, batched. Returns how
  /// many files were written.
  Future<int> flush() async {
    final dirty = _dirty.toList();
    for (final id in dirty) {
      final replica = _replicas[id];
      if (replica == null) continue; // Defensive: dirty implies opened.
      await _storage.saveFile(
        _path(NodeId(id)),
        jsonEncode(replica.toJson()),
        message: 'save doc replica $id',
      );
    }
    _dirty.removeAll(dirty);
    return dirty.length;
  }

  /// Flushes pending writes. The caller owns the store lifecycle; the
  /// attached [MeshStorageService] never disposes it.
  Future<void> dispose() => flush();

  /// Restores a replica from persisted [raw] JSON. Fast path: the file's
  /// actor is this store's actor → `DocReplica.fromJson`. Otherwise a
  /// fresh replica with THIS actor id re-derives the state from the
  /// file's durable op log (event-sourced: ops are the source of truth).
  DocReplica _restore(final NodeId docId, final String raw) {
    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } on Object catch (e) {
      throw FormatException('corrupt doc replica ${docId.value}: $e');
    }
    if (json['actor_id'] == actorId) {
      return DocReplica.fromJson(json);
    }
    final replica = DocReplica(nodeId: docId, actorId: actorId)
      ..applyRemote(_opsOf(raw));
    return replica;
  }

  /// The durable op log of a persisted replica JSON.
  static List<OpRecord> _opsOf(final String raw) {
    final json = jsonDecode(raw) as Map<dynamic, dynamic>;
    final doc = json['doc'];
    if (doc is! Map) return const [];
    final log = doc['log'];
    if (log is! List) return const [];
    return log
        .whereType<Map<dynamic, dynamic>>()
        .map((final e) => OpRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
