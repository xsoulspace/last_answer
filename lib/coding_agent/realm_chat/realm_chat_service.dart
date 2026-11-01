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

import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
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

  /// The recent beats of ONE thread (oldest → newest, newest last),
  /// read through the same kernel `read` the active-thread refresh
  /// uses (`_refreshBeats`): the human's actor authority, the given
  /// [threadId], bounded to [beatsForLimit]. The read is in-memory —
  /// the kernel replica — so polling it every couple of seconds (the
  /// peek's cadence) is cheap. An unknown thread, a not-yet-ready
  /// service or any kernel refusal reads as an empty list: this never
  /// throws and never notifies (a notifying read would loop its
  /// pollers).
  Future<List<Map<String, Object?>>> beatsFor(final String threadId) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return const <Map<String, Object?>>[];
    try {
      final read = await world.conversation().read(
            actor: human,
            threadId: threadId,
            limit: beatsForLimit,
          );
      return (read['beats']! as List).cast<Map<String, Object?>>().toList();
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
      // One-device-one-human heal: threads and channels minted before
      // the stable identity carry older per-launch human ids in their
      // participants — substitute the stable id so the human's own
      // history (channel clicks, DM threads) stays visible. Idempotent.
      try {
        await world.conversation().healHumanIdentity(stableActorId: humanId);
      } on Object {
        // Heal is best-effort; the world verbs still work.
      }
      // The dispatcher starts EARLY (it only needs the world + the
      // human id): its cursor seeds at the current lastBeat, so any
      // beat said after this moment is fresh. Slow steps (secure-store
      // keychain reads) follow — never between seed and first listen.
      _bots = RealmBotHost(
        world: world,
        humanActorId: humanId,
        resolveOpenRouterApiKey: () => _openRouterApiKey,
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
      await refreshThreads();
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

  /// Reloads the thread list (newest activity first).
  Future<void> refreshThreads() async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    try {
      final listing = await world.conversation().list(actor: human);
      _threads
        ..clear()
        ..addAll((listing['threads']! as List).cast<Map<String, Object?>>());
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
      );
      _activeThreadId = result['threadId']! as String;
      _beats.clear();
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

  void selectThread(String threadId) {
    if (_activeThreadId == threadId) return;
    _activeThreadId = threadId;
    _beats.clear();
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
      await world.conversation().close(actor: human, threadId: threadId);
      if (_activeThreadId == threadId) {
        _activeThreadId = null;
        _beats.clear();
      }
      await refreshThreads();
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> _refreshBeats() async {
    final world = _world;
    final human = _human;
    final threadId = _activeThreadId;
    if (world == null || human == null || threadId == null) return;
    try {
      final read = await world.conversation().read(
        actor: human,
        threadId: threadId,
        limit: 128,
      );
      _beats
        ..clear()
        ..addAll((read['beats']! as List).cast<Map<String, Object?>>());
      final last = read['lastBeat'];
      if (last is int) _pollCursor[threadId] = last;
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
    _bots?.stopAll();
    super.dispose();
  }
}
