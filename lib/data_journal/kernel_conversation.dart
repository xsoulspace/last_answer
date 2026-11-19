/// ADR 0025 — the thread/beat verb library over the ConvergenceDoc
/// kernel: one [DocReplica] per thread, beats as ordered child blocks.
///
/// Replaces the journal-backed `DurableConversation` behind
/// [RealmWorld.conversation] with the same verb surface (identical
/// signatures, identical result maps, identical [DurableRealmRefusal]
/// codes) so every caller keeps working unchanged:
///
/// * BEATS ARE KERNEL OPS. Block text = beat text (RGA lane), author /
///   addressedTo / at / beat ride block fields (LWW lane), block order =
///   beat order (fractional keys). Mesh-syncable by construction; the
///   int beat counter is position + 1 (also written as a block field so
///   migrated legacy numbers survive).
/// * THE JOURNAL KEEPS ONLY CHEAP INDEX RECORDS. One LA-owned
///   `thread_index` collection record per thread (the `channels`
///   pattern): metadata + `lastBeat` + the preview triple
///   (`lastBeatAuthor`/`lastBeatText`/`lastBeatAt`), so the service's
///   projection never scans a beat store. The kernel edit lands FIRST,
///   the index transact SECOND: a crash between them leaves the index
///   lagging while beat reads stay correct (and the next open or first
///   touch rebuilds the record from the doc — see `_indexFor`).
/// * `wait` PARKS ON CHANGE NOTIFICATIONS. [DocReplicaStore.changes]
///   fires on every committed edit; a waiter subscribes and sleeps on a
///   completer per wake — no polling, 0% idle. `timeoutMs` stays the
///   fallback and the timeout answer keeps the journal shape (empty
///   beats + the current cursors).
///
/// AUTHORIZATION LAW: participant/authority checks key on
/// `authority.actor` ONLY — never on docId/projectId fields (the same
/// actor presents authorities built two ways in this codebase:
/// `RealmWorld.authorityFor` and harness `RealmActorSession.authority`;
/// both must work). Visibility is participation: a thread exists for an
/// actor iff the actor is among its participants.
///
/// MIGRATION: on open, legacy journal `threads`/`thread_beats` records
/// of this project scope seed kernel docs (idempotent — a doc that was
/// born is never re-seeded); legacy records stay in place (additive —
/// the journal is shared with the live ecsaid daemon).
///
/// REPLICA HOME (ADR 0025 amendment): the docs persist under the thread
/// home passed to [load] — the realm's own project area, never
/// app-support — and any legacy in-scope replicas are adopted there by
/// copy (never move) on open.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The durable thread/beat store over one kernel replica per thread.
final class KernelConversation {
  KernelConversation._({
    required this._store,
    required this._root,
    required this._replicas,
    required this._threadsHome,
  });

  /// The realm's one control store: index records and legacy records
  /// live here; beats do not (they live in the kernel docs).
  final RealmControlStore _store;

  /// LA's project scope (the world `root`); the legacy-migration filter.
  final String _root;

  /// One ConvergenceDoc replica per thread, persisted under
  /// `<threadsHome>/<threadId>.json`.
  final DocReplicaStore _replicas;

  /// The replica home directory — the archive enumeration root for the
  /// journal export (a replica file can exist WITHOUT an index record:
  /// a crash between the kernel edit and the index commit leaves the
  /// doc as the truth and the record missing — the exporter must see
  /// the files, not only the index).
  final String _threadsHome;

  /// Actor id every kernel op issued here carries — stable across
  /// restarts so persisted replica files restore through the fast path.
  static const _replicaActorId = 'lastanswer-world';

  /// The thread-replica directory NAME — the one home literal (ADR 0025
  /// amendment). The durable home is the realm's own project area,
  /// `<device root>/.xsoulspace/worlds/<realm id>/project/lastanswer`
  /// plus this name (`RealmWorld.realmThreadsHome`); hermetic worlds use
  /// the override root plus this name. Durable state lives in the realm
  /// area — never app-support, never .dart_tool.
  static const threadsDirName = 'threads';

  /// The LA-owned index collection in the realm control store — the
  /// `channels` pattern: a dumb durable store of cheap records.
  static const _indexCollection = 'thread_index';

  static const maxThreadTextBytes = 8192;

  /// In-memory mirror of the index collection: loaded once at open,
  /// updated by every index commit. Verb hot paths never re-parse the
  /// journal (the 2.6MB+ shared journal re-parse per read was the cost
  /// this file exists to remove).
  final Map<String, Map<String, Object?>> _index = {};

  /// Waiters parked on the next committed edit (see `wait`).
  final _waiters = <Completer<void>>[];
  late final StreamSubscription<DocReplicaChange> _changesSub;

  /// Loads the conversation layer: adopts any legacy in-scope replica
  /// files into [threadsHome] (copy, never move), builds the filesystem
  /// replica store under it, loads the index, runs the legacy migration.
  ///
  /// [root] stays LA's project-scope root STRING unchanged — it seals
  /// authorities and membership records and filters the journal
  /// migration; only the replica DIRECTORY moved (ADR 0025 amendment).
  static Future<KernelConversation> load({
    required RealmControlStore store,
    required String root,
    required String threadsHome,
    bool migrateLegacy = true,
  }) async {
    final home = Directory(threadsHome);
    await _adoptLegacyReplicas(
      from: Directory('$root/$threadsDirName'),
      to: home,
    );
    // DocReplicaStore layout is `<provider base>/<dir>/<docId>.json`, so
    // the home's parent is the provider base and the home's own name is
    // the dir — the file layout under the home is unchanged.
    final provider = FileSystemStorageProvider();
    await provider.initWithConfig(
      FileSystemConfig(
        filePathConfig: FilePathConfig({'path': home.parent.path}),
      ),
    );
    final replicas = DocReplicaStore(
      storage: StorageService(provider),
      actorId: _replicaActorId,
      dir: home.path
          .split(Platform.pathSeparator)
          .lastWhere((segment) => segment.isNotEmpty),
    );
    final conversation = KernelConversation._(
      store: store,
      root: root,
      replicas: replicas,
      threadsHome: home.path,
    );
    conversation._changesSub = replicas.changes.listen((_) {
      for (final waiter in conversation._waiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
    });
    await conversation._loadIndex();
    // Plane convergence (2026-11-07): the journal is the beat plane
    // again (ADR 0138 D1 — one beat plane; the projection fold removed
    // the scan cost this kernel lane existed to avoid). The world loads
    // the kernel as the EXPORT SOURCE and archive — re-running the
    // journal→kernel migration would fight the kernel→journal export.
    if (migrateLegacy) await conversation._migrateLegacyThreads();
    return conversation;
  }

  /// Adopts replica files from the legacy in-scope home into the new
  /// one — COPY, never move (ADR 0025 amendment): the old copies stay
  /// as a safety net and are never deleted or rewritten. Idempotent by
  /// construction: a missing old home is a clean no-op and a name
  /// already present in the new home is never overwritten. Counts and
  /// logs nothing durable.
  static Future<void> _adoptLegacyReplicas({
    required Directory from,
    required Directory to,
  }) async {
    if (from.path == to.path || !from.existsSync()) return;
    await to.create(recursive: true);
    await for (final entity in from.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.path
          .split(Platform.pathSeparator)
          .lastWhere((segment) => segment.isNotEmpty);
      final target = File('${to.path}/$name');
      if (target.existsSync()) continue;
      await entity.copy(target.path);
    }
  }

  /// Cancels the change subscription (the world lives for the app run;
  /// hermetic tests may dispose early). Pending waiters time out.
  Future<void> dispose() async {
    await _changesSub.cancel();
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _waiters.clear();
  }

  Future<void> _loadIndex() async {
    _index
      ..clear()
      ..addAll(await _store.scan(_indexCollection));
  }

  // ---- the export face (plane convergence, 2026-11-07) ----

  /// The in-memory thread index (threadId → record) — the exporter's
  /// work list. Records mirror the last committed index state.
  Map<String, Map<String, Object?>> get index => Map.unmodifiable(_index);

  /// Every thread id with a replica FILE under the home — including
  /// docs whose index record never committed (the crash-window case
  /// the doc-as-truth law covers). The exporter enumerates this union
  /// so no archive beat is orphaned by a missing record.
  Set<String> archiveThreadIds() {
    final home = Directory(_threadsHome);
    if (!home.existsSync()) return const <String>{};
    final ids = <String>{};
    for (final entity in home.listSync(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.path
          .split(Platform.pathSeparator)
          .lastWhere((segment) => segment.isNotEmpty);
      if (!name.endsWith('.json')) continue;
      ids.add(name.substring(0, name.length - '.json'.length));
    }
    return ids;
  }

  /// Rebuilds one index record from its archive doc (the self-heal
  /// builder — the doc is the truth, the record is the cache). The
  /// exporter's source for file-only threads.
  Future<Map<String, Object?>> archiveRecordOf(String threadId) async {
    final replica = await _replicas.open(NodeId(threadId));
    return _indexRecordFromDoc(replica);
  }

  /// Every beat of one thread, oldest first, straight from the kernel
  /// doc — the exporter's source (see `RealmWorld.exportKernelThreads`).
  /// An unknown or empty thread reads as an empty list.
  Future<List<Map<String, Object?>>> beatsOf(String threadId) async {
    final replica = await _replicas.open(NodeId(threadId));
    return _docBeats(replica, threadId);
  }

  // ---- thread verbs (surface-identical to DurableConversation) ----

  /// One-device-one-human migration (ADR 0025): threads minted before
  /// the durable `world_identity` carry an older per-launch human id
  /// (`human-<process timestamp>`) in their participants — a fresh id
  /// every launch made every such thread invisible to the next one.
  /// Every participant matching that shape is THIS device's one human:
  /// substitute [stableActorId] in the doc and the index. Returns the
  /// healed thread count; a no-op once every thread carries the stable
  /// id.
  Future<int> healHumanIdentity({required String stableActorId}) async {
    final stale = RegExp(r'^human-\d+$');
    var healed = 0;
    for (final entry in _index.entries) {
      final participants =
          (entry.value['participants'] as List? ?? const <Object?>[])
              .cast<String>()
              .toList();
      final hasStale = participants.any(
        (id) => id != stableActorId && stale.hasMatch(id),
      );
      if (!hasStale) continue;
      final next = <String>{
        for (final id in participants) stale.hasMatch(id) ? stableActorId : id,
      }.toList()
        ..sort();
      final now = DateTime.now().toUtc();
      final threadId = entry.key;
      final replica = await _replicas.open(NodeId(threadId));
      if (replica.wasBorn) {
        await _replicas.edit(
          NodeId(threadId),
          (final r) => [
            ...r.setNodeField('participants', value: jsonEncode(next), now: now),
          ],
        );
        await _replicas.flush();
      }
      await _commitIndex(threadId, <String, Object?>{
        ...entry.value,
        'participants': next,
      });
      healed++;
    }
    return healed;
  }

  /// Opens a thread in the caller's project. The caller is the first
  /// participant; named participants are invited by id and join by
  /// acting (their first say).
  Future<Map<String, Object?>> open({
    required ActorAuthority actor,
    required String topic,
    List<String> participants = const <String>[],
  }) async {
    if (topic.trim().isEmpty) {
      throw const DurableRealmRefusal('thread_topic_missing');
    }
    final threadId = 'thread-${_mintId()}';
    final now = DateTime.now().toUtc();
    final invited = <String>{
      actor.actor,
      for (final name in participants)
        if (name.trim().isNotEmpty) name.trim(),
    }.toList()
      ..sort();
    await _replicas.edit(
      NodeId(threadId),
      // The birth fields make `wasBorn` true: a crash between this edit
      // and the index commit re-heals instead of re-seeding.
      (replica) => [
        ...replica.createNode(now: now),
        ...replica.setNodeField('topic', value: topic.trim(), now: now),
        ...replica.setNodeField('createdBy', value: actor.actor, now: now),
        ...replica.setNodeField('closed', value: 'false', now: now),
        ...replica.setNodeField(
          'participants',
          value: jsonEncode(invited),
          now: now,
        ),
      ],
    );
    await _replicas.flush();
    await _commitIndex(threadId, <String, Object?>{
      'threadId': threadId,
      'topic': topic.trim(),
      'createdBy': actor.actor,
      'createdAt': now.toIso8601String(),
      'closed': false,
      'participants': invited,
      'lastBeat': 0,
    });
    await accrueActorMembership(
      store: _store,
      actorId: actor.actor,
      projectRoot: actor.projectRoot,
      threadId: threadId,
    );
    return <String, Object?>{
      'ok': true,
      'threadId': threadId,
      'topic': topic.trim(),
      'participants': invited,
    };
  }

  /// Says one beat. Saying auto-joins: the author becomes a participant,
  /// which is the conversational presence — no separate join verb to
  /// forget.
  Future<Map<String, Object?>> say({
    required ActorAuthority actor,
    required String threadId,
    required String text,
    List<String> addressedTo = const <String>[],
    int? replyTo,
  }) async {
    final bytes = utf8.encode(text).length;
    if (bytes > maxThreadTextBytes) {
      throw DurableRealmRefusal(
        'thread_text_too_large: $bytes bytes exceeds '
        '$maxThreadTextBytes; split the turn.',
      );
    }
    final addressed = <String>[
      for (final name in addressedTo)
        if (name.trim().isNotEmpty) name.trim(),
    ];
    final record = await _visibleIndex(actor, threadId);
    final docId = NodeId(threadId);
    final replica = await _replicas.open(docId);
    if (_docClosed(replica)) {
      throw const DurableRealmRefusal('thread_closed');
    }
    final blockId = NodeId('beat-${_mintId()}');
    final at = DateTime.now().toUtc();
    // The beat counter and the joined participants are computed INSIDE
    // the edit, from the doc's own state, so concurrent says can never
    // mint the same beat number.
    var beat = 0;
    String participantsJson = '';
    await _replicas.edit(docId, (doc) {
      beat = doc.orderedChildren(threadId).length + 1;
      final participants = <String>{
        ..._docParticipants(doc),
        actor.actor,
      }.toList()
        ..sort();
      participantsJson = jsonEncode(participants);
      return [
        ...doc.addBlock(
          Block(id: blockId, type: BlockType.paragraph, content: text),
        ),
        ...doc.setBlockField(blockId, 'author', value: actor.actor, now: at),
        ...doc.setBlockField(
          blockId,
          'beat',
          value: '$beat',
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'at',
          value: at.toIso8601String(),
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'addressedTo',
          value: jsonEncode(addressed),
          now: at,
        ),
        if (replyTo != null)
          ...doc.setBlockField(blockId, 'replyTo', value: '$replyTo', now: at),
        ...doc.setNodeField('participants', value: participantsJson, now: at),
      ];
    });
    await _replicas.flush();
    // Index AFTER the kernel edit: a crash between them leaves the index
    // lagging (previews/cursors) while beat reads stay kernel-correct.
    await _commitIndex(threadId, <String, Object?>{
      ...record,
      'participants': (jsonDecode(participantsJson) as List).cast<String>(),
      'lastBeat': beat,
      'lastBeatAuthor': actor.actor,
      'lastBeatText': text,
      'lastBeatAt': at.toIso8601String(),
    });
    await accrueActorMembership(
      store: _store,
      actorId: actor.actor,
      projectRoot: actor.projectRoot,
      threadId: threadId,
    );
    return <String, Object?>{
      'ok': true,
      'threadId': threadId,
      'beat': beat,
      'addressedTo': addressed,
    };
  }

  /// Reads one thread's beats, oldest first, straight from the kernel
  /// replica — no journal scan.
  Future<Map<String, Object?>> read({
    required ActorAuthority actor,
    required String threadId,
    int afterBeat = 0,
    int limit = 64,
  }) async {
    final record = await _visibleIndex(actor, threadId);
    final replica = await _replicas.open(NodeId(threadId));
    final beats = _docBeats(replica, threadId);
    final after = [
      for (final beat in beats)
        if ((beat['beat']! as int) > afterBeat) beat,
    ];
    final page = after.take(limit.clamp(1, 128)).toList();
    return <String, Object?>{
      'ok': true,
      'threadId': threadId,
      'topic': record['topic'],
      'closed': record['closed'],
      'participants': _docParticipants(replica),
      'beats': page,
      'lastBeat': record['lastBeat'],
      'hasMore': after.length > page.length,
    };
  }

  /// Waits for the next beat worth waking for: in [threadId] when named,
  /// otherwise across this actor's open threads, and (by default) only
  /// beats addressed to this actor — the listening actor's door knock.
  ///
  /// Parks on replica change notifications between scans (0% idle);
  /// [timeoutMs] is the fallback and the timeout answer keeps the
  /// journal shape: empty `beats`, the current cursors, `timedOut`.
  /// Beat numbers are PER THREAD, so a cross-thread cursor is a map:
  /// pass [afterByThread] (or [afterBeat] for the single-thread form);
  /// the answer always carries `lastBeatByThread` so the next call
  /// resumes exactly where this one stopped.
  Future<Map<String, Object?>> wait({
    required ActorAuthority actor,
    String? threadId,
    bool addressedToMe = true,
    int afterBeat = 0,
    Map<String, int> afterByThread = const <String, int>{},
    int timeoutMs = 30000,
  }) async {
    final clock = Stopwatch()..start();
    if (threadId != null) await _visibleIndex(actor, threadId);
    while (true) {
      // Arm the wake BEFORE scanning and keep it armed while parked: a
      // change committed mid-scan either shows up in this scan or
      // completes the wake; a change while parked completes it here.
      final wake = Completer<void>();
      _waiters.add(wake);
      try {
        final threadIds = threadId != null
            ? <String>[threadId]
            : <String>[
                for (final entry in _index.entries)
                  if (entry.value['closed'] != true &&
                      ((entry.value['participants'] as List? ?? const [])
                          .cast<String>()
                          .contains(actor.actor)))
                    entry.key,
              ];
        final (hits, cursors) = await _scanBeats(
          actorId: actor.actor,
          threadIds: threadIds,
          addressedToMe: addressedToMe,
          afterBeat: afterBeat,
          afterByThread: afterByThread,
        );
        if (hits.isNotEmpty || clock.elapsedMilliseconds >= timeoutMs) {
          return <String, Object?>{
            'ok': true,
            'beats': hits,
            'lastBeat':
                threadId == null ? null : (cursors[threadId] ?? afterBeat),
            'lastBeatByThread': cursors,
            'timedOut': hits.isEmpty,
          };
        }
        final remaining = timeoutMs - clock.elapsedMilliseconds;
        await wake.future.timeout(
          Duration(milliseconds: remaining.clamp(1, 1 << 31)),
          onTimeout: () {},
        );
      } finally {
        _waiters.remove(wake);
      }
    }
  }

  /// The actor's threads, newest creation first, from the in-memory
  /// index — no journal scan, no beat store. Each thread map carries the
  /// preview triple (`lastBeatAuthor`/`lastBeatText`/`lastBeatAt`) so
  /// the service's projection stops scanning for last beats entirely.
  Future<Map<String, Object?>> list({required ActorAuthority actor}) async {
    final threads =
        <Map<String, Object?>>[
          for (final record in _index.values)
            if ((record['participants'] as List? ?? const <Object?>[])
                .cast<String>()
                .contains(actor.actor))
              record,
        ]..sort(
          (a, b) => (b['createdAt']! as String).compareTo(
            a['createdAt']! as String,
          ),
        );
    return <String, Object?>{
      'ok': true,
      'threads': [
        for (final record in threads.take(50))
          <String, Object?>{
            'threadId': record['threadId'],
            'topic': record['topic'],
            'createdBy': record['createdBy'],
            'createdAt': record['createdAt'],
            'closed': record['closed'],
            'participants': record['participants'],
            'lastBeat': record['lastBeat'],
            if (record['lastBeatAuthor'] != null)
              'lastBeatAuthor': record['lastBeatAuthor'],
            if (record['lastBeatText'] != null)
              'lastBeatText': record['lastBeatText'],
            if (record['lastBeatAt'] != null)
              'lastBeatAt': record['lastBeatAt'],
          },
      ],
      'total': threads.length,
    };
  }

  /// Closes a thread. Any participant may close: the conversation
  /// belongs to its participants, not to its opener alone.
  Future<Map<String, Object?>> close({
    required ActorAuthority actor,
    required String threadId,
  }) async {
    final record = await _visibleIndex(actor, threadId);
    final docId = NodeId(threadId);
    final replica = await _replicas.open(docId);
    final participants = _docParticipants(replica);
    if (!participants.contains(actor.actor)) {
      throw const DurableRealmRefusal('thread_close_not_participant');
    }
    final now = DateTime.now().toUtc();
    await _replicas.edit(
      docId,
      (doc) => [
        ...doc.setNodeField('closed', value: 'true', now: now),
        ...doc.setNodeField('closedAt', value: now.toIso8601String(), now: now),
      ],
    );
    await _replicas.flush();
    await _commitIndex(threadId, <String, Object?>{
      ...record,
      'closed': true,
      'closedAt': now.toIso8601String(),
    });
    return <String, Object?>{'ok': true, 'threadId': threadId, 'closed': true};
  }

  // ---- internals ----

  /// The visible (participating) index record for [threadId], or the
  /// `thread_not_visible` refusal — keyed on `authority.actor` only.
  Future<Map<String, Object?>> _visibleIndex(
    ActorAuthority actor,
    String threadId,
  ) async {
    final record = await _indexFor(threadId);
    if (record == null ||
        !(record['participants'] as List? ?? const <Object?>[])
            .cast<String>()
            .contains(actor.actor)) {
      throw const DurableRealmRefusal('thread_not_visible');
    }
    return record;
  }

  /// The index record for [threadId], self-healed from the kernel doc
  /// when missing (the crash window: kernel edit committed, index
  /// transact not). Null when no thread ever lived under this id.
  Future<Map<String, Object?>?> _indexFor(String threadId) async {
    final record = _index[threadId];
    if (record != null) return record;
    final replica = await _replicas.open(NodeId(threadId));
    if (!replica.wasBorn) return null;
    final healed = _indexRecordFromDoc(replica);
    await _commitIndex(threadId, healed);
    return healed;
  }

  /// Commits one index record (journal) and mirrors it into memory.
  Future<void> _commitIndex(
    String threadId,
    Map<String, Object?> record,
  ) async {
    await _store.transact((tx) => tx.put(_indexCollection, threadId, record));
    _index[threadId] = record;
  }

  /// Beats of one thread doc, oldest first. Order = block order
  /// (fractional keys); the int beat is the stored field, falling back
  /// to position + 1.
  List<Map<String, Object?>> _docBeats(DocReplica replica, String threadId) {
    final blockIds = replica.orderedChildren(threadId);
    final beats = <Map<String, Object?>>[];
    for (var i = 0; i < blockIds.length; i++) {
      final blockId = NodeId(blockIds[i]);
      final addressedRaw = replica.blockFieldOf(blockId, 'addressedTo');
      final replyTo = replica.blockFieldOf(blockId, 'replyTo');
      beats.add(<String, Object?>{
        'threadId': threadId,
        'beat':
            int.tryParse(replica.blockFieldOf(blockId, 'beat') ?? '') ?? i + 1,
        'author': replica.blockFieldOf(blockId, 'author') ?? '',
        'text': replica.blockText(blockId),
        'at': replica.blockFieldOf(blockId, 'at') ?? '',
        'addressedTo': addressedRaw == null
            ? <String>[]
            : (jsonDecode(addressedRaw) as List).cast<String>(),
        if (replyTo != null) 'replyTo': int.tryParse(replyTo),
      });
    }
    beats.sort(
      (a, b) => (a['beat']! as int).compareTo(b['beat']! as int),
    );
    return beats;
  }

  /// One wake scan across [threadIds]: beats past each cursor, filtered
  /// by addressing, cursors advancing only over kept beats (the journal
  /// `wait` contract the bot dispatcher resumes through).
  Future<(List<Map<String, Object?>>, Map<String, int>)> _scanBeats({
    required String actorId,
    required List<String> threadIds,
    required bool addressedToMe,
    required int afterBeat,
    required Map<String, int> afterByThread,
  }) async {
    final hits = <Map<String, Object?>>[];
    final cursors = <String, int>{...afterByThread};
    for (final id in threadIds) {
      final seen = cursors[id] ?? afterBeat;
      final replica = await _replicas.open(NodeId(id));
      for (final beat in _docBeats(replica, id)) {
        if ((beat['beat']! as int) <= seen) continue;
        final addressed = (beat['addressedTo']! as List).cast<String>();
        if (addressedToMe && !addressed.contains(actorId)) continue;
        if (hits.length < 32) hits.add(beat);
        cursors[id] = beat['beat']! as int;
      }
      // Threads with no new beats keep their cursor (or the seed).
      cursors[id] ??= seen;
    }
    return (hits, cursors);
  }

  bool _docClosed(DocReplica replica) =>
      replica.blockFieldOf(replica.nodeId, 'closed') == 'true';

  List<String> _docParticipants(DocReplica replica) {
    final raw = replica.blockFieldOf(replica.nodeId, 'participants');
    if (raw == null || raw.isEmpty) return const <String>[];
    return (jsonDecode(raw) as List).cast<String>();
  }

  String? _docField(DocReplica replica, String name) =>
      replica.blockFieldOf(replica.nodeId, name);

  /// Builds one index record from a kernel doc — the migration and
  /// self-heal path (the doc is the truth; the record is the cache).
  Map<String, Object?> _indexRecordFromDoc(DocReplica replica) {
    final threadId = replica.nodeId.value;
    final beats = _docBeats(replica, threadId);
    final last = beats.isEmpty ? null : beats.last;
    return <String, Object?>{
      'threadId': threadId,
      'topic': _docField(replica, 'topic') ?? '',
      'createdBy': _docField(replica, 'createdBy') ?? '',
      'createdAt':
          _docField(replica, 'createdAt') ??
          replica.document().createdAt.toIso8601String(),
      'closed': _docClosed(replica),
      'participants': _docParticipants(replica),
      'lastBeat': beats.isEmpty ? 0 : beats.last['beat'],
      if (last != null) ...<String, Object?>{
        'lastBeatAuthor': last['author'],
        'lastBeatText': last['text'],
        'lastBeatAt': last['at'],
      },
    };
  }

  /// Legacy migration: journal `threads`/`thread_beats` records of this
  /// project scope seed kernel docs and index records. Idempotent — a
  /// doc that was born is never re-seeded (its index record is simply
  /// (re)built from the doc); legacy records stay in place, untouched
  /// (the journal is shared with the live ecsaid daemon).
  Future<void> _migrateLegacyThreads() async {
    final pending = <String, Map<String, Object?>>{
      for (final entry in (await _store.scan('threads')).entries)
        if (!_index.containsKey(entry.key) &&
            entry.value['projectRoot'] == _root)
          entry.key: entry.value,
    };
    if (pending.isEmpty) return;
    final legacyBeats = <String, List<Map<String, Object?>>>{};
    for (final beat in (await _store.scan('thread_beats')).values) {
      final threadId = beat['threadId']! as String;
      if (!pending.containsKey(threadId)) continue;
      (legacyBeats[threadId] ??= <Map<String, Object?>>[]).add(beat);
    }
    final records = <String, Map<String, Object?>>{};
    for (final entry in pending.entries) {
      final threadId = entry.key;
      final docId = NodeId(threadId);
      final replica = await _replicas.open(docId);
      if (!replica.wasBorn) {
        final beats =
            (legacyBeats[threadId] ?? const <Map<String, Object?>>[])
                .toList()
                  ..sort(
                    (a, b) =>
                        (a['beat']! as int).compareTo(b['beat']! as int),
                  );
        await _replicas.edit(docId, (doc) => _seedOps(doc, entry.value, beats));
        await _replicas.flush();
      }
      records[threadId] = _indexRecordFromDoc(replica);
    }
    await _store.transact((tx) {
      for (final entry in records.entries) {
        tx.put(_indexCollection, entry.key, entry.value);
      }
    });
    _index.addAll(records);
  }

  /// The kernel ops seeding one legacy thread: metadata node fields +
  /// one block per legacy beat (order = beat order).
  List<OpRecord> _seedOps(
    DocReplica doc,
    Map<String, Object?> thread,
    List<Map<String, Object?>> beats,
  ) {
    final createdAt =
        DateTime.tryParse(thread['createdAt']! as String) ??
        DateTime.now().toUtc();
    final participants = (thread['participants']! as List).cast<String>();
    final ops = [
      ...doc.createNode(now: createdAt),
      ...doc.setNodeField(
        'topic',
        value: thread['topic']! as String,
        now: createdAt,
      ),
      ...doc.setNodeField(
        'createdBy',
        value: thread['createdBy']! as String? ?? '',
        now: createdAt,
      ),
      ...doc.setNodeField(
        'closed',
        value: thread['closed'] == true ? 'true' : 'false',
        now: createdAt,
      ),
      ...doc.setNodeField(
        'participants',
        value: jsonEncode(participants),
        now: createdAt,
      ),
    ];
    for (final beat in beats) {
      final blockId = NodeId('beat-${_mintId()}');
      final at = DateTime.tryParse(beat['at']! as String) ?? createdAt;
      final replyTo = beat['replyTo'];
      ops.addAll([
        ...doc.addBlock(
          Block(
            id: blockId,
            type: BlockType.paragraph,
            content: beat['text']! as String,
          ),
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'author',
          value: beat['author']! as String,
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'beat',
          value: '${beat['beat']! as int}',
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'at',
          value: beat['at']! as String,
          now: at,
        ),
        ...doc.setBlockField(
          blockId,
          'addressedTo',
          value: jsonEncode(
            (beat['addressedTo']! as List? ?? const <Object?>[]).cast<String>(),
          ),
          now: at,
        ),
        if (replyTo != null)
          ...doc.setBlockField(
            blockId,
            'replyTo',
            value: '$replyTo',
            now: at,
          ),
      ]);
    }
    return ops;
  }
}

/// 12 hex chars from [Random.secure] — byte-identical in shape to the
/// harness's `DurableConversation._mintId`, so one id vocabulary spans
/// threads, channels and beat blocks.
String _mintId() {
  final random = Random.secure();
  return List<String>.generate(
    12,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
