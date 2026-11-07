/// ADR 0023 — the world chat service: the app-scoped composition behind
/// the chat surface.
///
/// Owns the [RealmWorld], the human's external-actor identity, the
/// [RealmBotHost] loops, and the projected thread/beat state the chat
/// surface renders. All conversation state is durable in the world
/// store; this class holds only projections and cursors.
///
/// Started lazily on first use (opening a chat doc or the Settings
/// actors pane) and stays alive for the app run, so bot-to-bot
/// conversation continues while no surface watches.
library;

import 'dart:async' show StreamSubscription, Timer, unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_creation.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The durable-conversation projection + bot runtime for one app run.
final class RealmChatService extends ChangeNotifier {
  RealmChatService({
    this._providerConfiguration,
    this.debugWorldOverride,
    this.debugRosterOverride,
    @visibleForTesting this._debugStartBotDispatcher = true,
  }) {
    debugInstances.add(this);
  }

  /// Debug seam for the agent intents (like AgentDocSurface.debugState):
  /// the live instances, newest last. Never read in product code paths.
  static final List<RealmChatService> debugInstances = <RealmChatService>[];

  final ProviderConfigurationStore? _providerConfiguration;

  /// Test seams: a hermetic world/roster overrides the real opens (the
  /// widget tests bind a disposable world; production passes null). The
  /// dispatcher flag keeps the bot runtime's 30s wake timer out of
  /// widget tests. Visible for testing only — never set from product.
  @visibleForTesting
  final RealmWorld? debugWorldOverride;
  @visibleForTesting
  final ActorRoster? debugRosterOverride;

  /// Test seam: overrides the projected narration so widget tests bind
  /// actor activity without running bot loops. Never set from product.
  @visibleForTesting
  Map<String, BotNarration>? debugNarrationOverride;
  final bool _debugStartBotDispatcher;

  RealmWorld? _world;
  RealmBotHost? _bots;
  ActorRoster? _roster;
  ProfileActorAuthority? _human;
  ChannelRegistry? _channelRegistry;
  Future<void>? _starting;
  bool _ready = false;
  bool _disposed = false;
  String? _error;
  String? _openRouterApiKey;

  /// False on web (no filesystem world); the surface shows a named note.
  bool get isSupported => !kIsWeb;

  bool get isReady => _ready;
  String? get error => _error;
  RealmBotHost? get bots => _bots;
  ActorRoster? get roster => _roster;

  /// Wave 3A — the actors' activity narration (what each bot is doing
  /// right now), projected from the bot host; empty when no host runs.
  /// Narration changes notify through [notifyListeners] — the host's
  /// `onChanged` is wired to it.
  Map<String, BotNarration> get botNarration =>
      debugNarrationOverride ??
      _bots?.narrations ??
      const <String, BotNarration>{};

  String? get humanActorId => _human?.actor;

  // ---- G6 seams (the shell wires these from WorldStateService) ----

  /// The discovered palette's rung facts for a `cast:` brainRef.
  CastBrainDecl? Function(String entryId)? resolveCastRung;

  /// Whether the harness daemon's actor loops are armed right now.
  bool Function()? daemonLiveGetter;

  /// Credential resolution by env NAME (palette rungs).
  String? Function(String envName)? resolveCredential;

  /// actorId → the durable realm row's `brainCast` (the daemon's binding
  /// vocabulary, written by `actor_bind`): the defer law's second half.
  final Map<String, String> _realmBrainCasts = {};

  /// The defer predicate's BINDING half: whether this actor is bound in
  /// the daemon's own vocabulary (`cast:` brainRefs and durable
  /// `brainCast` rows) — independent of the daemon being live right
  /// now. The chat's honest-absence row (0f) reads this: a bound actor
  /// with a SLEEPING daemon is exactly when the room must say so.
  bool daemonBoundActor(final ActorProfile actor) {
    if (actor.brainRef.trim().startsWith('cast:')) return true;
    final cast = _realmBrainCasts[actor.actorId];
    return cast != null && cast.isNotEmpty;
  }

  /// G6 — the defer-to-daemon predicate: a live daemon owns the actors
  /// bound in its own vocabulary (`cast:` brainRefs and durable
  /// `brainCast` rows); the in-app host stays out of their threads.
  bool daemonOwnsActor(final ActorProfile actor) {
    if (daemonLiveGetter?.call() != true) return false;
    return daemonBoundActor(actor);
  }

  /// Re-reads the durable `brainCast` bindings (the daemon may bind an
  /// actor between app wakes; the defer law must see it).
  Future<void> refreshBrainCasts() async {
    final world = _world;
    if (world == null) return;
    try {
      final records = await world.store.scan('realm_actors');
      _realmBrainCasts
        ..clear()
        ..addEntries(
          records.values
              .where(
                (final record) =>
                    record['brainCast'] is String &&
                    (record['brainCast']! as String).isNotEmpty,
              )
              .map(
                (final record) => MapEntry(
                  '${record['actorId']}',
                  record['brainCast']! as String,
                ),
              ),
        );
    } on Object {
      // An unreadable row keeps the previous binding view.
    }
  }

  /// Thread projections from `thread.list` (newest activity first).
  List<Map<String, Object?>> get threads => List.unmodifiable(_threads);

  /// ADR 0024 — registered channels (oldest first), cached from
  /// [ChannelRegistry.list]; refreshed on start and after each
  /// [createChannel].
  List<ChannelInfo> get channels => List.unmodifiable(_channels);

  /// The channel registered over [threadId], null for plain threads
  /// (DMs, unregistered groups).
  ChannelInfo? channelByThreadId(final String threadId) {
    for (final channel in _channels) {
      if (channel.threadId == threadId) return channel;
    }
    return null;
  }

  /// threadId → one-line preview of the thread's last beat
  /// (`<author display name>: <text>`, truncated) for the thread pane.
  Map<String, String> beatPreviews() => Map.unmodifiable(_beatPreviews);

  /// Beat projections of the active thread (oldest first).
  List<Map<String, Object?>> get beats => List.unmodifiable(_beats);

  /// The bounded read [beatsFor] asks the kernel for (ADR 0027: the
  /// miniwindow peek's poll size).
  static const int beatsForLimit = 50;

  /// The recent beats of ONE thread (oldest → newest, newest last):
  /// the folded projection's TAIL, bounded to [beatsForLimit]. Pure
  /// read — no receipt advance (a peek must not mark a room seen) and
  /// no notify (a notifying read would loop its pollers). An unknown
  /// thread, a not-yet-ready service or any fold failure reads as an
  /// empty list: this never throws.
  Future<List<Map<String, Object?>>> beatsFor(final String threadId) async {
    final world = _world;
    if (world == null) return const <Map<String, Object?>>[];
    try {
      final all = await world.projection.beatsOfThread(threadId);
      if (all.length <= beatsForLimit) return all;
      return all.sublist(all.length - beatsForLimit);
    } on Object {
      return const <Map<String, Object?>>[];
    }
  }

  bool get sending => _sending;

  String? _activeThreadId;

  /// The open thread id, null = none selected.
  String? get activeThreadId => _activeThreadId;

  /// The active thread's projection, null when none selected.
  Map<String, Object?>? get activeThread {
    for (final thread in _threads) {
      if (thread['threadId'] == _activeThreadId) return thread;
    }
    return null;
  }

  final List<Map<String, Object?>> _threads = <Map<String, Object?>>[];
  final List<Map<String, Object?>> _beats = <Map<String, Object?>>[];
  final List<ChannelInfo> _channels = <ChannelInfo>[];
  final Map<String, String> _beatPreviews = <String, String>{};
  String _previewSignature = '';
  bool _sending = false;
  final Map<String, int> _pollCursor = <String, int>{};

  /// The journal's append watch (live surfaces): every append — the
  /// human's own say, an in-app bot's reply, a daemon-owned actor's
  /// beat, an external seat's message — fires one debounced refresh of
  /// threads + the active thread's beats. Independent of the bot host's
  /// onWake, so deferred (daemon-owned) actors update the UI too.
  StreamSubscription<void>? _journalSub;
  Timer? _journalDebounce;

  /// The active thread's loaded window start (index into the folded
  /// beat list). Null = not paged yet (tail view on first refresh);
  /// [loadOlderBeats] walks it toward 0.
  int? _windowStart;

  /// Opens the world, mints/loads the human identity, registers it, and
  /// starts the bots + the wake loop. Idempotent; a failed start may be
  /// retried by calling again.
  Future<void> ensureReady() async {
    if (_ready || _disposed || !isSupported) return;
    await (_starting ??= _start());
    if (!_ready) _starting = null;
  }

  Future<void> _start() async {
    try {
      final world = debugWorldOverride ?? await RealmWorld.open();
      if (world == null) {
        _error = 'realm_world_unsupported';
        return;
      }
      _world = world;
      _roster =
          debugRosterOverride ??
          StorageBackendsNotifier.instance.ensureActorRoster();
      final humanId = await _resolveStableHumanId(world);
      if (_roster!.get(humanId) == null) {
        _roster!.upsert(
          ActorProfile(
            actorId: humanId,
            displayName: 'Human',
            kind: ActorKind.human,
          ),
        );
      }
      await world.registerActor(humanId);
      // Re-materialize identities from the world (the durable home):
      // any registered actor carrying a profile lands back in the
      // roster, so bots survive an app restart without a mesh.
      final records = await world.store.scan('realm_actors');
      for (final record in records.values) {
        final brain = record['brainRef'] as String?;
        if (brain == null || brain.isEmpty) continue;
        final actorId = record['actorId']! as String;
        if (_roster!.get(actorId) != null) continue;
        _roster!.upsert(
          ActorProfile(
            actorId: actorId,
            displayName: record['displayName'] as String? ?? actorId,
            kind: ActorKind.values.firstWhere(
              (kind) => kind.name == record['actorKind'],
              orElse: () => ActorKind.model,
            ),
            brainRef: brain,
            role: record['role'] as String? ?? '',
            systemPrompt: record['systemPrompt'] as String? ?? '',
          ),
        );
      }
      _human = world.authorityFor(humanId);
      // One-device-one-human heal + plane convergence (2026-11-07):
      // heal the kernel archive, export its threads into the journal
      // (the ONE beat plane — ADR 0138 D1; realm-sealed so daemon-owned
      // actors and external seats answer in the same rooms), then heal
      // the journal rows. All three idempotent, all best-effort.
      try {
        await world.kernel.healHumanIdentity(stableActorId: humanId);
        await world.exportKernelThreads();
        await world.healJournalHumanIdentity(stableActorId: humanId);
      } on Object {
        // Best-effort; refreshThreads surfaces what landed.
      }
      // The dispatcher starts EARLY (it only needs the world + the
      // human id): its cursor seeds at the current lastBeat, so any
      // beat said after this moment is fresh. Slow steps (secure-store
      // keychain reads) follow — never between seed and first listen.
      _bots = RealmBotHost(
        world: world,
        humanActorId: humanId,
        resolveOpenRouterApiKey: () => _openRouterApiKey,
        resolveCast: (final entryId) => resolveCastRung?.call(entryId),
        resolveCredential: (final envName) =>
            resolveCredential?.call(envName) ??
            readInferenceCredential(envName),
        daemonOwnsActor: daemonOwnsActor,
        debugStartDispatcher: _debugStartBotDispatcher,
        onChanged: notifyListeners,
        onWake: (_) {
          unawaited(refreshThreads());
          if (_activeThreadId != null) unawaited(_refreshBeats());
        },
      );
      syncBots();
      final store = _providerConfiguration;
      _openRouterApiKey = store == null
          ? Platform.environment['OPENROUTER_API_KEY']
          : await store.readProviderKey(AgentPlatformConfig.openRouterId) ??
                Platform.environment['OPENROUTER_API_KEY'];
      final registry = _channelRegistry = ChannelRegistry(store: world.store);
      try {
        await registry.healHumanIdentity(stableActorId: humanId);
      } on Object {
        // Heal is best-effort; the registry still lists.
      }
      await _refreshChannels();
      await refreshBrainCasts();
      await refreshThreads();
      _journalSub = world.watchJournal().listen((_) {
        if (_disposed) return;
        _journalDebounce?.cancel();
        _journalDebounce = Timer(const Duration(milliseconds: 300), () {
          if (_disposed) return;
          unawaited(refreshThreads());
          if (_activeThreadId != null) unawaited(_refreshBeats());
        });
      });
      _ready = true;
    } on Object catch (error) {
      _error = error.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Aligns bot loops with the roster (start new, stop removed).
  void syncBots() => _bots?.syncBots(_roster?.all ?? const <ActorProfile>[]);

  /// The human's actor id is a DURABLE WORLD identity (ADR 0025: the
  /// world record is the identity): stored once in a LA-owned
  /// `world_identity` record and re-adopted on every start. A per-process
  /// replica id would mint a fresh human each launch and orphan every
  /// kernel thread's participant list at the first restart.
  Future<String> _resolveStableHumanId(final RealmWorld world) async {
    final records = await world.store.scan('world_identity');
    final stored = records['human']?['actorId'] as String?;
    if (stored != null && stored.isNotEmpty) return stored;
    final minted = 'human-${_roster!.replicaId}';
    await world.store.transact((tx) {
      tx.put('world_identity', 'human', <String, Object?>{
        'actorId': minted,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    });
    return minted;
  }

  /// Mints one actor identity (the shared human/actor-spawn mechanism)
  /// and starts its loop when it has a runnable brain.
  Future<ActorProfile?> createActor({
    required String displayName,
    required ActorKind kind,
    required String brainRef,
    String role = '',
    String systemPrompt = '',
  }) async {
    final world = _world;
    final roster = _roster;
    if (world == null || roster == null) return null;
    final profile = await createActorIdentity(
      roster: roster,
      world: world,
      displayName: displayName,
      kind: kind,
      brainRef: brainRef,
      role: role,
      systemPrompt: systemPrompt,
    );
    syncBots();
    return profile;
  }

  /// ADR 0023 §1a — edits one actor identity in place (the ONE edit
  /// mechanism, behind both surfaces: the context column's actor panel
  /// and the Settings actors pane). Null fields keep today's value; an
  /// empty string clears (the persona may be deliberately emptied). The
  /// durable world record is re-registered, so the edit survives
  /// restarts, and the bot loops are re-synced — a materially changed
  /// profile (brain/persona/name) rebuilds its worker
  /// ([RealmBotHost.syncBots]).
  ///
  /// Refuses an unknown [actorId] with a named error (`unknown_actor:<id>`)
  /// and returns false; the caller keeps its editor open.
  Future<bool> updateActor({
    required String actorId,
    String? displayName,
    String? role,
    String? systemPrompt,
    String? brainRef,
  }) async {
    final world = _world;
    final roster = _roster;
    if (world == null || roster == null) {
      _error = 'realm_not_ready';
      notifyListeners();
      return false;
    }
    try {
      await updateActorIdentity(
        roster: roster,
        world: world,
        actorId: actorId,
        displayName: displayName,
        role: role,
        systemPrompt: systemPrompt,
        brainRef: brainRef,
      );
    } on UnknownActorException {
      _error = 'unknown_actor:$actorId';
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
    syncBots();
    notifyListeners();
    return true;
  }

  void removeActor(String actorId) {
    final roster = _roster;
    if (roster == null) return;
    removeActorIdentity(roster, actorId);
    _bots?.stopBot(actorId);
    syncBots();
  }

  // ---- thread verbs (the human's words) ----

  /// Reloads the room list (newest activity first) from the folded
  /// journal projection — NOT the `list` verb: rooms are realm-sealed
  /// (the verb's project filter would hide them) and endless (the verb
  /// caps at 50). Visibility for the human = the same three-way law
  /// the harness applies to agents: realm-sealed rooms, the app's own
  /// project scope, and durably granted projects. Preview triples are
  /// enriched from the folded beats (journal rows carry only the
  /// `lastBeat` counter).
  Future<void> refreshThreads() async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    unawaited(refreshBrainCasts());
    try {
      final projection = world.projection;
      final rows = await projection.threadRows();
      final grants = await projection.grantsOf(human.actor);
      final enriched = <Map<String, Object?>>[];
      for (final row in rows.values) {
        final project = row['projectId'];
        final visible =
            project == null ||
            project == human.projectId ||
            grants.contains(project);
        if (!visible) continue;
        final threadId = '${row['threadId'] ?? ''}';
        if (threadId.isEmpty) continue;
        final beats = await projection.beatsOfThread(threadId);
        final last = beats.isEmpty ? null : beats.last;
        enriched.add(<String, Object?>{
          ...row,
          if (last != null) ...<String, Object?>{
            'lastBeatAuthor': last['author'],
            'lastBeatText': last['text'],
            'lastBeatAt': last['at'],
          },
        });
      }
      String activityOf(final Map<String, Object?> row) =>
          (row['lastBeatAt'] ?? row['createdAt'] ?? '') as String;
      enriched.sort(
        (a, b) => activityOf(b).compareTo(activityOf(a)),
      );
      _threads
        ..clear()
        ..addAll(enriched);
      final active = _activeThreadId;
      if (active != null &&
          !_threads.any((thread) => thread['threadId'] == active)) {
        _activeThreadId = null;
        _beats.clear();
      }
      await _refreshBeatPreviews();
    } on Object catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  /// Opens a thread with the human plus the named participants.
  Future<void> startThread({
    required String topic,
    List<String> participants = const <String>[],
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    try {
      final result = await world.conversation().open(
        actor: human,
        topic: topic.trim().isEmpty ? 'Conversation' : topic.trim(),
        participants: participants,
        // Realm-sealed (ADR 0121): the room belongs to the realm, not
        // to LA's project scope — daemon-owned actors, external seats
        // and in-app loops all see and answer in it.
        realmSealed: true,
      );
      _activeThreadId = result['threadId']! as String;
      _beats.clear();
      _windowStart = null;
      await refreshThreads();
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  // ---- actor + channel verbs (ADR 0024: the rail lists ACTORS and
  // CHANNELS, not chats) ----

  /// The open two-member thread {human, [actorId]}, null when no DM
  /// exists yet. Closed threads are not reused (says refuse there), so
  /// a re-opened DM gets a fresh thread.
  String? dmThreadOf(final String actorId) {
    final human = humanActorId;
    if (human == null || actorId == human) return null;
    for (final thread in _threads) {
      if (thread['closed'] == true) continue;
      final participants =
          (thread['participants'] as List? ?? const <Object?>[])
              .cast<String>()
              .toSet();
      if (participants.length == 2 &&
          participants.contains(human) &&
          participants.contains(actorId)) {
        return thread['threadId']! as String;
      }
    }
    return null;
  }

  /// Opens the DM with [actorId]: the existing two-member thread with
  /// the human (reused, never duplicated), else a new one titled with
  /// the actor's display name. Selects the thread either way.
  Future<void> openDm(final String actorId) async {
    final existing = dmThreadOf(actorId);
    if (existing != null) {
      selectThread(existing);
      await refreshThreads();
      return;
    }
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    final displayName =
        _roster?.get(actorId)?.displayName ?? actorDisplayFallback(actorId);
    await startThread(topic: displayName, participants: <String>[actorId]);
  }

  /// Opens a named channel: a durable thread (existing before anyone
  /// speaks) plus a `channels` registry record in the same realm store.
  /// Refuses empty and duplicate names (case-insensitive) with a named
  /// error and a null result; on success the channel is selected.
  Future<ChannelInfo?> createChannel(
    final String name, {
    final List<String> memberIds = const <String>[],
  }) async {
    final world = _world;
    final human = _human;
    final registry = _channelRegistry;
    if (world == null || human == null || registry == null) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      _error = 'channel_name_empty';
      notifyListeners();
      return null;
    }
    final exists = _channels.any(
      (channel) => channel.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      _error = 'channel_name_taken';
      notifyListeners();
      return null;
    }
    final members = <String>{
      human.actor,
      for (final id in memberIds)
        if (id.trim().isNotEmpty) id.trim(),
    }.toList()..sort();
    try {
      final opened = await world.conversation().open(
        actor: human,
        topic: trimmed,
        participants: members,
        // Realm-sealed like every LA room (see startThread).
        realmSealed: true,
      );
      final threadId = opened['threadId']! as String;
      final channel = await registry.create(
        name: trimmed,
        threadId: threadId,
        memberIds: members,
      );
      await _refreshChannels();
      _activeThreadId = threadId;
      _beats.clear();
      _windowStart = null;
      await refreshThreads();
      return channel;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return null;
    }
  }

  /// Selects the thread the named channel talks in (no-op when unknown).
  void selectChannel(final String channelId) {
    for (final channel in _channels) {
      if (channel.channelId == channelId) {
        selectThread(channel.threadId);
        return;
      }
    }
  }

  Future<void> _refreshChannels() async {
    final registry = _channelRegistry;
    if (registry == null) return;
    try {
      final channels = await registry.list();
      _channels
        ..clear()
        ..addAll(channels);
    } on Object catch (error) {
      _error = error.toString();
    }
  }

  /// Rebuilds the last-beat previews from the thread list itself
  /// (ADR 0025): each thread record now carries the preview triple
  /// (`lastBeatAuthor`/`lastBeatText`/`lastBeatAt`) from its journal
  /// index record, so no beat store is ever scanned. The signature
  /// guard keeps quiet refreshes from rebuilding the map.
  Future<void> _refreshBeatPreviews() async {
    final lastByThread = <String, int>{
      for (final thread in _threads)
        thread['threadId']! as String: thread['lastBeat']! as int,
    };
    final signature = lastByThread.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join('|');
    if (signature == _previewSignature) return;
    String nameOf(final String actorId) =>
        _roster?.get(actorId)?.displayName ?? actorDisplayFallback(actorId);
    _beatPreviews
      ..clear()
      ..addAll(<String, String>{
        for (final thread in _threads)
          if (thread['lastBeatText'] is String &&
              (thread['lastBeatText']! as String).isNotEmpty &&
              thread['lastBeatAuthor'] is String)
            thread['threadId']! as String: _truncatePreview(
              '${nameOf(thread['lastBeatAuthor']! as String)}: '
              '${thread['lastBeatText']! as String}',
            ),
      });
    _previewSignature = signature;
  }

  static String _truncatePreview(final String raw) {
    final text = raw.replaceAll('\n', ' ');
    const max = 80;
    if (text.length <= max) return text;
    return '${text.substring(0, max - 1)}…';
  }

  /// Returns the Conversations surface to its LANDING state (the phase
  /// 1d inbox): no thread selected. The rail/edge "show me what needs
  /// attention" affordances route here — the inbox is the overview, and
  /// a persisted tab never hides it.
  void clearActiveThread() {
    if (_activeThreadId == null) return;
    _activeThreadId = null;
    _beats.clear();
    _windowStart = null;
    notifyListeners();
  }

  void selectThread(String threadId) {
    if (_activeThreadId == threadId) return;
    _activeThreadId = threadId;
    _beats.clear();
    _windowStart = null;
    unawaited(_refreshBeats());
  }

  /// Says one beat as the human, addressed to the thread's other
  /// participants (so every bot in the thread hears it).
  Future<void> say(String text) async {
    final world = _world;
    final human = _human;
    final threadId = _activeThreadId;
    final trimmed = text.trim();
    if (world == null || human == null || threadId == null || trimmed.isEmpty) {
      return;
    }
    final others = [
      for (final participant
          in (activeThread?['participants'] as List? ?? const <Object?>[])
              .cast<String>())
        if (participant != human.actor) participant,
    ];
    _sending = true;
    notifyListeners();
    try {
      await world.conversation().say(
        actor: human,
        threadId: threadId,
        text: trimmed,
        addressedTo: others,
      );
      // The in-process shortcut: our own append dispatches immediately
      // (the journal watch covers everyone else's).
      _bots?.nudgeDispatcher();
      await _refreshBeats();
    } on DurableRealmRefusal catch (refusal) {
      _error = refusal.code;
    } on Object catch (error) {
      _error = error.toString();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> closeThread(String threadId) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    try {
      await world.closeThread(actor: human, threadId: threadId);
      if (_activeThreadId == threadId) {
        _activeThreadId = null;
        _beats.clear();
        _windowStart = null;
      }
      await refreshThreads();
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  /// The active thread's tail page size — the first view shows the
  /// NEWEST [tailPageSize] beats (never the thread's head: an endless
  /// room lives at its tail), and [loadOlderBeats] walks the window
  /// toward the beginning one page at a time.
  static const int tailPageSize = 128;

  /// Whether the active thread has older beats above the loaded window.
  bool get hasOlderBeats => (_windowStart ?? 0) > 0;

  /// Extends the active thread's window one [tailPageSize] page toward
  /// the thread's beginning (the chat surface's scroll-up trigger).
  /// Prepend-only: the loaded tail never changes, so the surface keeps
  /// its scroll position.
  Future<void> loadOlderBeats() async {
    final world = _world;
    final threadId = _activeThreadId;
    if (world == null || threadId == null) return;
    try {
      final all = await world.projection.beatsOfThread(threadId);
      final start =
          _windowStart ??
          (all.length > tailPageSize ? all.length - tailPageSize : 0);
      if (start <= 0) return;
      final next = start - tailPageSize;
      _windowStart = next < 0 ? 0 : next;
      _beats
        ..clear()
        ..addAll(all.sublist(_windowStart!));
    } on Object catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<void> _refreshBeats() async {
    final world = _world;
    final human = _human;
    final threadId = _activeThreadId;
    if (world == null || human == null || threadId == null) return;
    try {
      // The folded projection answers in memory (O(delta) refreshes);
      // the window is a tail slice — an endless thread never
      // re-materializes into the UI whole.
      final all = await world.projection.beatsOfThread(threadId);
      final start =
          _windowStart ??
          (all.length > tailPageSize ? all.length - tailPageSize : 0);
      _windowStart = start > all.length ? all.length : start;
      _beats
        ..clear()
        ..addAll(all.sublist(_windowStart!));
      // Reading IS the read receipt (ADR 0124): the human's cursor
      // advances to the newest beat, so rail badges and the inbox stop
      // counting what this surface just showed.
      if (all.isNotEmpty) {
        final lastBeat = all.last['beat'];
        if (lastBeat is int) {
          _pollCursor[threadId] = lastBeat;
          await advanceReadReceipt(
            store: world.store,
            actorId: human.actor,
            threadId: threadId,
            upToBeat: lastBeat,
          );
        }
      }
    } on Object catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    debugInstances.remove(this);
    _disposed = true;
    _ready = false;
    _journalDebounce?.cancel();
    unawaited(_journalSub?.cancel() ?? Future<void>.value());
    _bots?.stopAll();
    super.dispose();
  }
}
