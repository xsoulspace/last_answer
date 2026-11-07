// ADR 0107 — one world per realm; Last Answer enrolls as a project
// scope.
//
// The realm's ONE durable coordination store lives in the harness's own
// device tree, not under this app's support directory:
//
//     <device root>/.xsoulspace/worlds/<realm id>/coordination/
//       realm_control.journal    the append journal (the whole world)
//       realm_control.lock       the cross-process writer lock
//       realm_control.torn-*.bin forensic torn-tail captures
//
// `<device root>` resolves exactly like the harness's
// `harnessDeviceHome()` (pkgs/xsoulspace_agentic_host
// `src/harness_paths.dart`): the `HARNESS_HOME` override, then
// `HOME`/`USERPROFILE`, then the system temp directory. The realm id is
// `local`, the harness default; naming another realm is the owner
// operator's job (`HARNESS_REALM_ID` and the config membership
// pointer), not a client's guess.
//
// Opening that store does not fight the realm owner: the store is the
// realm's coordination authority, so the owner, its seats and this app
// all write through the same OS-level lock on the lock file, ordered
// per process by the store's serial lane. Last Answer's app-support
// directory (`<support>/world`) remains the PROJECT SCOPE every thread
// is sealed to — a scope inside the one world, never a world of its
// own. On web there is no filesystem and the surface answers with a
// named unsupported note.
//
// ADR 0025 amendment — the kernel thread replicas live in the realm's
// own project area (`<realm world>/project/lastanswer/threads`), not in
// app-support: the support directory henceforth keeps only disposable
// state, and any legacy in-scope replica files are adopted there by
// copy (never move) on open.
//
// ADR 0023 — Last Answer's own ecsai realm. The app-level world where
// conversations live as durable threads over one journaled
// [RealmControlStore]: the human is an external actor, roster bots are
// internal actors with a brain binding, and the chat surface is a
// projection of the `thread` verb family — never a private message
// table.

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:lastanswer/coding_agent/realm_chat/kernel_conversation.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world_root_io.dart'
    if (dart.library.js_interop) 'realm_world_root_stub.dart'
    as world_root;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The durable world: the realm's one control store, LA's project
/// scope, and the human's authority.
final class RealmWorld {
  RealmWorld._({
    required this.store,
    required this.root,
    required this._kernel,
    required this._journal,
  });

  /// Directory name of the realm's coordination store inside its parent
  /// (`coordination` follows the harness daemon's layout — the same
  /// directory the realm owner serves; see `durable_seat_host.dart`).
  static const storeDirName = 'coordination';

  /// The app-support subdirectory that is LA's project scope.
  static const _projectScopeDirName = 'world';

  /// Directory names of the realm project area hosting the kernel
  /// thread replicas (ADR 0025 amendment):
  /// `<realm world>/project/lastanswer/threads`.
  static const _realmProjectDirName = 'project';
  static const _realmProjectAppDirName = 'lastanswer';

  /// The env override naming the device root — the harness's
  /// `harnessHomeEnv` (`src/harness_paths.dart`).
  static const _deviceHomeEnv = 'HARNESS_HOME';

  /// The harness's default realm id (`defaultRealmId` in
  /// `src/harness_paths.dart`).
  static const _realmId = 'local';

  final RealmControlStore store;

  /// The project scope every thread is sealed to — LA's app-support
  /// scope inside the realm's one world (ADR 0107 D1).
  final String root;

  /// The kernel-backed thread/beat archive (ADR 0025 — retired as the
  /// live plane by the 2026-11-07 plane convergence: ADR 0138 D1 makes
  /// the journal the ONE beat plane, and the cursor-fed projection fold
  /// removed the whole-collection scan cost the kernel lane existed to
  /// avoid). Kept as the EXPORT SOURCE ([exportKernelThreads]) and the
  /// offline archive; new beats never land here.
  final KernelConversation _kernel;

  /// The journal-backed conversation verbs (the live beat plane):
  /// threads/beats as `RealmControlStore` collections, read through the
  /// cursor-fed [ConversationProjection] (ADR 0126/0138 D2), visible to
  /// every actor of the realm — daemon-owned actors, external seats and
  /// the in-app loops all ride the same plane.
  final DurableConversation _journal;

  bool get isSupported => !kIsWeb;

  static RealmWorld? _instance;

  /// Opens (or reuses) the app-level world over the realm's ONE control
  /// store. Desktop only; web returns null and callers show the
  /// unsupported note. [rootOverride] points the world at a hermetic
  /// directory (tests and gates); it bypasses both the singleton and
  /// the realm home by design.
  static Future<RealmWorld?> open({String? rootOverride}) async {
    if (kIsWeb) return null;
    if (rootOverride != null) return _openHermetic(rootOverride);
    return _instance ??= await _openRealm();
  }

  /// Production: the canonical realm control store under the realm
  /// world home, with LA's app-support project scope and the kernel
  /// replica home in the realm's project area (any legacy in-scope
  /// replica files are adopted there by copy on open — ADR 0025
  /// amendment).
  static Future<RealmWorld> _openRealm() async {
    final storeDir = Directory(realmControlStorePath());
    await storeDir.create(recursive: true);
    final store = RealmControlStore(storeDir);
    final root =
        '${await world_root.resolveProjectScopeBase()}'
        '/$_projectScopeDirName';
    return RealmWorld._(
      store: store,
      root: root,
      kernel: await KernelConversation.load(
        store: store,
        root: root,
        threadsHome: realmThreadsHome(),
        migrateLegacy: false,
      ),
      journal: DurableConversation(store: store),
    );
  }

  /// Hermetic (tests and gates): the same shape inside a disposable
  /// directory — `<override>/world` as the project scope, its
  /// `coordination/` as the store, `<override>/threads` as the kernel
  /// replica home.
  static Future<RealmWorld> _openHermetic(String override) async {
    final scopeRoot = '$override/$_projectScopeDirName';
    final storeDir = Directory('$scopeRoot/$storeDirName');
    await storeDir.create(recursive: true);
    final store = RealmControlStore(storeDir);
    return RealmWorld._(
      store: store,
      root: scopeRoot,
      kernel: await KernelConversation.load(
        store: store,
        root: scopeRoot,
        threadsHome: '$override/${KernelConversation.threadsDirName}',
        migrateLegacy: false,
      ),
      journal: DurableConversation(store: store),
    );
  }

  /// The realm world home (ADR 0107):
  /// `<device root>/.xsoulspace/worlds/<realm id>` — the parent of both
  /// the coordination store and the thread-replica project area.
  static String get _realmWorldHome =>
      '${deviceHome()}/.xsoulspace/worlds/$_realmId';

  /// ADR 0107 — the realm's ONE control store directory:
  /// `<device root>/.xsoulspace/worlds/<realm id>/coordination`.
  static String realmControlStorePath() => '$_realmWorldHome/$storeDirName';

  /// ADR 0025 amendment — the kernel thread replica home, inside the
  /// realm's own project area (durable state never in app-support):
  /// `<device root>/.xsoulspace/worlds/<realm id>/project/lastanswer/threads`.
  static String realmThreadsHome() =>
      '$_realmWorldHome'
      '/$_realmProjectDirName/$_realmProjectAppDirName/'
      '${KernelConversation.threadsDirName}';

  /// The device root: `HARNESS_HOME` override, then `HOME`/
  /// `USERPROFILE`, then the system temp directory — the harness's own
  /// `harnessDeviceHome()` resolution, mirrored because
  /// `harness_paths.dart` is not part of the host package's public
  /// surface. Tests may pin [debugDeviceHome] (an env var cannot be set
  /// in-process).
  static String deviceHome() {
    final override = debugDeviceHome ?? Platform.environment[_deviceHomeEnv];
    if (override != null && override.isNotEmpty) return override;
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) return home;
    return Directory.systemTemp.path;
  }

  /// Tests only: pins [deviceHome] to a hermetic directory root so a
  /// realm-shaped open resolves every durable path under it.
  @visibleForTesting
  static String? debugDeviceHome;

  /// The durable thread/beat verb library — the JOURNAL plane (ADR
  /// 0138 D1: one beat plane). Surface-identical to the kernel lane it
  /// replaces, so callers keep their shapes; reads ride the cursor-fed
  /// [projection] under the hood.
  DurableConversation conversation() => _journal;

  /// The kernel archive (retired as the live plane): the export source
  /// for [exportKernelThreads] and the offline beat archive.
  KernelConversation get kernel => _kernel;

  /// The cursor-fed conversation projection over this world's store
  /// (ADR 0126/0138 D2): one per store per process, O(delta) refreshes.
  /// Tail pages, thread rows and grant sets all read from here.
  ConversationProjection get projection => conversationProjectionFor(store);

  /// The journal's append watch — the wake source for live surfaces
  /// (chat appends, the bot dispatcher's drain). A hint only: readers
  /// always re-read the exact tail (`changesSince`).
  Stream<void> watchJournal({
    Duration pollInterval = const Duration(milliseconds: 400),
  }) => store.watch(pollInterval: pollInterval);

  /// Plane convergence (2026-11-07): exports every kernel-archive
  /// thread into the journal — the reverse of the ADR 0025 migration,
  /// additive and idempotent (a beat key `$threadId#$beat` is a put of
  /// the same value; a thread row is created once, then merged).
  /// Exported threads are REALM-SEALED (no project): visible to every
  /// actor of the realm — the daemon's drain, external seats and the
  /// in-app loops answer in the same rooms (ADR 0121: plain
  /// conversation needs no project). Returns the exported thread count.
  Future<int> exportKernelThreads() async {
    var exported = 0;
    // The union: index records AND bare replica files (a crash between
    // the kernel edit and the index commit leaves the doc as the truth
    // and the record missing — file-only threads export too, rebuilt
    // through the archive's self-heal record).
    final ids = <String>{..._kernel.index.keys, ..._kernel.archiveThreadIds()};
    for (final threadId in ids) {
      final record =
          _kernel.index[threadId] ?? await _kernel.archiveRecordOf(threadId);
      final kernelLast = (record['lastBeat'] as int?) ?? 0;
      final existing = await store.read('threads', threadId);
      final priorLast = (existing?['lastBeat'] as int?) ?? 0;
      // Fast skip: the journal already carries everything the archive
      // counted — no beat load, no write (the idempotent reopen path).
      if (existing != null && priorLast >= kernelLast) continue;
      final beats = await _kernel.beatsOf(threadId);
      final fresh = [
        for (final beat in beats)
          if ((beat['beat']! as int) > priorLast) beat,
      ];
      if (existing != null && fresh.isEmpty) continue;
      final participants = <String>{
        ...(existing?['participants'] as List? ?? const <Object?>[])
            .cast<String>(),
        ...(record['participants'] as List? ?? const <Object?>[])
            .cast<String>(),
      }.toList()
        ..sort();
      final lastBeat = beats.isEmpty
          ? priorLast
          : (beats.last['beat']! as int) > priorLast
          ? beats.last['beat']! as int
          : priorLast;
      final last = beats.isEmpty ? null : beats.last;
      await store.transact((tx) {
        tx.put('threads', threadId, <String, Object?>{
          'threadId': threadId,
          // Realm-sealed: the room belongs to the realm, not to LA's
          // project scope — every actor may converse here.
          'projectId': null,
          'projectRoot': null,
          'topic': existing?['topic'] ?? record['topic'] ?? '',
          'createdBy': existing?['createdBy'] ?? record['createdBy'] ?? '',
          'createdAt':
              existing?['createdAt'] ??
              record['createdAt'] ??
              DateTime.now().toUtc().toIso8601String(),
          'closed': (existing?['closed'] ?? record['closed'] ?? false) == true,
          if (existing?['closedAt'] != null) 'closedAt': existing!['closedAt'],
          'participants': participants,
          'lastBeat': lastBeat,
          if (last != null) ...<String, Object?>{
            'lastBeatAuthor': last['author'],
            'lastBeatText': last['text'],
            'lastBeatAt': last['at'],
          } else ...<String, Object?>{
            if (existing?['lastBeatAuthor'] != null)
              'lastBeatAuthor': existing!['lastBeatAuthor'],
            if (existing?['lastBeatText'] != null)
              'lastBeatText': existing!['lastBeatText'],
            if (existing?['lastBeatAt'] != null)
              'lastBeatAt': existing!['lastBeatAt'],
          },
        });
        for (final beat in fresh) {
          tx.put('thread_beats', '$threadId#${beat['beat']}', <String, Object?>{
            'threadId': threadId,
            'beat': beat['beat'],
            'author': beat['author'],
            'conversationId': 'lastanswer',
            'text': beat['text'],
            'at': beat['at'],
            'addressedTo': beat['addressedTo'],
            if (beat['replyTo'] != null) 'replyTo': beat['replyTo'],
          });
        }
        return null;
      });
      exported++;
    }
    return exported;
  }

  /// The journal-plane twin of [KernelConversation.healHumanIdentity]:
  /// substitutes THIS device's one stable human id for stale per-launch
  /// `human-<timestamp>` participants in journal thread rows. Returns
  /// the healed row count; idempotent.
  Future<int> healJournalHumanIdentity({required String stableActorId}) async {
    final stale = RegExp(r'^human-\d+$');
    var healed = 0;
    for (final entry in (await projection.threadRows()).entries) {
      final participants =
          (entry.value['participants'] as List? ?? const <Object?>[])
              .cast<String>()
              .toList();
      if (!participants.any(
        (id) => id != stableActorId && stale.hasMatch(id),
      )) {
        continue;
      }
      final next = <String>{
        for (final id in participants)
          if (stale.hasMatch(id)) stableActorId else id,
      }.toList()
        ..sort();
      final row = entry.value;
      await store.transact(
        (tx) => tx.put('threads', entry.key, <String, Object?>{
          ...row,
          'participants': next,
        }),
      );
      healed++;
    }
    return healed;
  }

  /// Closes one room. Project-sealed threads ride the journal verb;
  /// REALM-SEALED rooms close through the store directly — the verb's
  /// participant check is right but its project check refuses the null
  /// seal (filed as a harness surface gap; LA is a journal writer like
  /// any seat, and `registerActor` sets the direct-write precedent).
  Future<void> closeThread({
    required ActorAuthority actor,
    required String threadId,
  }) async {
    final row = await store.read('threads', threadId);
    if (row == null) {
      throw const DurableRealmRefusal('thread_not_visible');
    }
    if (row['projectId'] != null) {
      await _journal.close(actor: actor, threadId: threadId);
      return;
    }
    final participants =
        (row['participants'] as List? ?? const <Object?>[]).cast<String>();
    if (!participants.contains(actor.actor)) {
      throw const DurableRealmRefusal('thread_close_not_participant');
    }
    await store.transact(
      (tx) => tx.put('threads', threadId, <String, Object?>{
        ...row,
        'closed': true,
        'closedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  /// One actor's working session over this world — the drop-in shape
  /// the bot host binds per actor (the same members it reads on the
  /// harness `RealmActorSession`): [authority] for the verb surfaces,
  /// [register] for the durable `realm_actors` record, [say] for one
  /// kernel beat under this actor's own identity.
  RealmWorldSession sessionFor(String actorId) =>
      RealmWorldSession._(world: this, actorId: actorId);

  /// The authority for the signed-in human. The id is derived from the
  /// device's durable replica id so it is stable across restarts; the
  /// caller passes it in (the roster owns the replica id).
  ProfileActorAuthority authorityFor(String actorId) => ProfileActorAuthority(
    actor: actorId,
    conversationId: 'lastanswer',
    actorReference: 'persistent-entity:realm-actor:$actorId',
    projectId: root,
    projectRoot: root,
  );

  /// Registers a durable `realm_actors` record (who exists, what it
  /// serves, and — for LA-minted actors — the profile that lets a fresh
  /// process re-materialize the identity: the world is the durable
  /// identity; the roster is its synced projection). Idempotent.
  Future<void> registerActor(
    String actorId, {
    List<String> serves = const <String>['conversation'],
    String displayName = '',
    String actorKind = '',
    String brainRef = '',
    String role = '',
    String? systemPrompt,
  }) async {
    await store.transact((tx) {
      final existing = tx.get('realm_actors', actorId);
      tx.put('realm_actors', actorId, <String, Object?>{
        'actorId': actorId,
        'kind': 'realm_actor',
        'docId': 'lastanswer',
        'registeredAt':
            existing?['registeredAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
        'lastSeenAt': DateTime.now().toUtc().toIso8601String(),
        'serves': <String>{
          ...(existing?['serves'] as List? ?? const <Object?>[]).cast<String>(),
          ...serves,
        }.toList()..sort(),
        // Profile fields are write-once-with-preservation: a plain
        // re-register (e.g. a bot's first session register) must never
        // wipe the durable profile a fresh process adopts from — the
        // world record IS the identity (ADR 0025).
        'displayName':
            (displayName.isNotEmpty
                ? displayName
                : existing?['displayName'] as String?) ??
            '',
        'actorKind': actorKind.isNotEmpty
            ? actorKind
            : existing?['actorKind'] as String? ?? '',
        'brainRef': brainRef.isNotEmpty
            ? brainRef
            : existing?['brainRef'] as String? ?? '',
        'role': role.isNotEmpty ? role : existing?['role'] as String? ?? '',
        // The persona is nullable ON PURPOSE: null = untouched (a plain
        // re-register preserves), '' = cleared by an owner-approved
        // profile edit. The other fields keep their isNotEmpty convention.
        'systemPrompt':
            systemPrompt ?? existing?['systemPrompt'] as String? ?? '',
        if (existing?['projects'] != null) 'projects': existing!['projects'],
        if (existing?['lastThreadId'] != null)
          'lastThreadId': existing?['lastThreadId'],
      });
    });
  }
}

/// One actor's working session over its world (ADR 0025): the LA-side
/// facade matching the harness `RealmActorSession` members the bot host
/// uses — [authority], [register], [say] — with the conversation verbs
/// riding the kernel thread docs instead of the journal.
final class RealmWorldSession {
  RealmWorldSession._({required this.world, required String actorId})
    : actorId = actorId,
      authority = world.authorityFor(actorId);

  final RealmWorld world;

  /// This actor's id (the world's durable identity).
  final String actorId;

  /// This actor's authority: identity + project scope (built by
  /// [RealmWorld.authorityFor], so it carries the app's own doc/project
  /// scoping).
  final ProfileActorAuthority authority;

  /// Writes the durable `realm_actors` record (idempotent) — the same
  /// record the harness session's `register` writes, through the
  /// world's own registration verb.
  Future<Map<String, Object?>> register({
    List<String> serves = const <String>[],
  }) async {
    await world.registerActor(actorId, serves: serves);
    return <String, Object?>{'ok': true, 'actorId': actorId};
  }

  /// Says one beat into a thread under this actor's identity; returns
  /// the beat number (the harness session's `say` shape).
  Future<int> say(
    String threadId,
    String text, {
    List<String> addressedTo = const <String>[],
    int? replyTo,
  }) async {
    final result = await world.conversation().say(
      actor: authority,
      threadId: threadId,
      text: text,
      addressedTo: addressedTo,
      replyTo: replyTo,
    );
    return result['beat']! as int;
  }
}
