import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

/// The durable `realm_actors` collection (the row shape is the ADR 0120
/// contract; LA is a reader here).
const String actorRowsCollection = 'realm_actors';

/// The incremental actor-bindings projection (ADR 0120/0143 read path).
///
/// WHY this exists: `refreshBrainCasts` used to re-scan the whole
/// `realm_actors` table on every journal event (the refresh runs under
/// `refreshThreads`), so a 2000-actor world paid a full-table read per
/// event. This fold reads the table ONCE (the cold
/// fold), anchors a byte cursor, and then applies only the
/// `realm_actors` mutations from the journal tail — the same TailFold
/// pattern the LA world feed applies to its projection. A replaced
/// journal generation (offset invalid) refolds from scratch — never
/// partial trust.
///
/// The maps are the SAME views the service exposed before (brainCast →
/// actor, brainSet → ordered allowed set, selfBind → row override);
/// only the read cost changed.
final class ActorBindingsFold {
  ActorBindingsFold(this._store);

  final RealmControlStore _store;

  /// Null until the first cold fold; a journal generation replacement
  /// resets it to null so the next [refresh] refolds from zero.
  int? _cursor;

  final Map<String, String> _brainCasts = {};
  final Map<String, List<String>> _brainSets = {};
  final Map<String, String> _selfBinds = {};

  /// actorId → current `brainCast` (non-empty rows only).
  Map<String, String> get brainCasts => Map.unmodifiable(_brainCasts);

  /// actorId → the actor's ordered brain set (an entry exists even when
  /// the set is empty — "declared and cleared" is a fact).
  Map<String, List<String>> get brainSets => Map.unmodifiable(_brainSets);

  /// actorId → the per-actor self-rebind override (`allow` | `deny`).
  Map<String, String> get selfBinds => Map.unmodifiable(_selfBinds);

  /// Cold-folds a scan the caller already made (the bind-time roster
  /// re-materialization reads the same table): adopt its records and
  /// anchor the cursor so [refresh] goes incremental instead of
  /// scanning the table twice at bind.
  void adoptScan(final Iterable<Map<String, Object?>> records) {
    _clear();
    records.forEach(_foldRow);
    _cursor = _store.journalLength();
  }

  /// Folds the actor rows: the full table on the first call, then only
  /// the journal tail. Read failures RE-THROW — the caller decides the
  /// staleness law (the service keeps the previous binding view); a
  /// replaced generation refolds here.
  Future<void> refresh() async {
    final cursor = _cursor;
    if (cursor == null) {
      adoptScan((await _store.scan(actorRowsCollection)).values);
      return;
    }
    final RealmControlChanges changes;
    try {
      changes = await _store.changesSince(cursor);
    } on RealmControlStoreException catch (error) {
      if (error.code != RealmControlStoreCode.offsetInvalid) rethrow;
      // A replaced generation: drop everything and refold from zero
      // (the TailFold rebuild-on-shrink law — never partial trust).
      _clear();
      await refresh();
      return;
    }
    if (changes.isEmpty) return;
    for (final record in changes.records) {
      for (final mutation in record.mutations) {
        if (mutation.collection != actorRowsCollection) continue;
        if (mutation.isRemove) {
          _dropRow(mutation.key);
        } else if (mutation.value != null) {
          _foldRow(mutation.value!);
        }
      }
    }
    _cursor = changes.newByteOffset;
  }

  void _clear() {
    _brainCasts.clear();
    _brainSets.clear();
    _selfBinds.clear();
    _cursor = null;
  }

  void _dropRow(final String actorId) {
    _brainCasts.remove(actorId);
    _brainSets.remove(actorId);
    _selfBinds.remove(actorId);
  }

  /// One put: the binding maps mirror the row's fields. A retired row
  /// keeps its bindings (retirement marks; it never destroys).
  void _foldRow(final Map<String, Object?> record) {
    final actorId = record['actorId'];
    if (actorId is! String || actorId.isEmpty) return;
    final cast = record['brainCast'];
    if (cast is String && cast.isNotEmpty) {
      _brainCasts[actorId] = cast;
    } else {
      _brainCasts.remove(actorId);
    }
    _brainSets[actorId] = <String>[
      if (record['brainSet'] is List)
        for (final entry in record['brainSet']! as List)
          if (entry is String && entry.isNotEmpty) entry,
    ];
    final selfBind = record['selfBind'];
    if (selfBind is String && selfBind.isNotEmpty) {
      _selfBinds[actorId] = selfBind;
    } else {
      _selfBinds.remove(actorId);
    }
  }
}
