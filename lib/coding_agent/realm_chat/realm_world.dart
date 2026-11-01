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
    required this._conversation,
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

  /// The kernel-backed thread/beat verb library (ADR 0025): one
  /// ConvergenceDoc replica per thread under the thread home — the
  /// realm project area in realm mode (`realmThreadsHome()`),
  /// `<override>/threads` hermetic — and cheap index records in the
  /// journal. Built once at open — the migration from legacy journal
  /// threads runs there.
  final KernelConversation _conversation;

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
      conversation: await KernelConversation.load(
        store: store,
        root: root,
        threadsHome: realmThreadsHome(),
      ),
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
      conversation: await KernelConversation.load(
        store: store,
        root: scopeRoot,
        threadsHome: '$override/${KernelConversation.threadsDirName}',
      ),
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

  /// The durable thread/beat verb library — kernel-backed (ADR 0025),
  /// surface-identical to the journal `DurableConversation` it replaced.
  KernelConversation conversation() => _conversation;

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
    docId: 'lastanswer',
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
