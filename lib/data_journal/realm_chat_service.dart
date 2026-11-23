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
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/data_agents/acp/acp_turn_worker.dart';
import 'package:lastanswer/data_agents/config/provider_configuration.dart';
import 'package:lastanswer/data_journal/actor_bindings_fold.dart';
import 'package:lastanswer/data_journal/actor_creation.dart';
import 'package:lastanswer/data_journal/realm_bot_host.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/data_journal/work_thread_spawn.dart';
import 'package:lastanswer/ecs_plugins/conversation/conversation_spaces.dart';
import 'package:lastanswer/ui_chat/actor_brain.dart';
import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/ui_settings/features/storage_backends_state.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

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

  /// The opened world (null until ready / on web) — the store access
  /// seam for world-adjacent surfaces (LaWorld's fold rides this, so
  /// hermetic overrides flow and the real singleton is never opened
  /// around them).
  RealmWorld? get world => _world;
  RealmBotHost? _bots;
  ActorRoster? _roster;

  /// The RETIRED durable rows by actor id (wave N5b): retirement is
  /// world truth (ADR 0120) — the surface names it verbatim instead of
  /// rendering a read-only "no roster profile" ghost.
  final Map<String, Map<String, Object?>> _retiredRows =
      <String, Map<String, Object?>>{};

  /// The retired row's facts (retiredAt, retireReason), null when the
  /// actor is not retired.
  Map<String, Object?>? retiredInfo(final String actorId) =>
      _retiredRows[actorId];

  /// The RETIRED durable rows, keyed by actor id: the projection the
  /// visibility surfaces read (the rooms column's muted rows, the
  /// people view's and the settings pane's Retired sections). A
  /// retirement invisible in every list is a lie of absence — the row
  /// keeps its history and the lists name it (2026-11-18).
  Map<String, Map<String, Object?>> get retiredRows => _retiredRows;

  ProfileActorAuthority? _human;
  ChannelRegistry? _channelRegistry;
  WorkThreadRegistry? _workRegistry;
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

  /// The subscription resolver the shell wires (ADR 0031): chatgpt/grok
  /// actors ride the signed-in providers. Null refuses every
  /// `subscription:` ref — the actor names nothing this host can run.
  /// Read THROUGH the field at bot-host construction (the shell sets it
  /// after the service constructs — the latest value wins).
  /// RECONSTRUCTED 2026-11-18 after a parallel lane's rewrite lost the
  /// original member (app_shell's wiring is the contract).
  ResolveSubscription? resolveSubscription;

  /// The ACP worker factory the shell wires. Null means an `acp:` actor
  /// has no voice. Read at sync time, so a factory set after the host
  /// is constructed still applies.
  AcpTurnWorker? Function(ActorProfile actor)? createAcpWorker;

  /// The incremental actor-bindings fold (ADR 0120/0143 read path):
  /// the `realm_actors` table is read ONCE at bind (adopted from the
  /// roster re-materialization's scan), then only journal-tail
  /// mutations apply — the 2000-actor law (a full-table read per
  /// journal event does not scale). Null until bind.
  ActorBindingsFold? _bindingsFold;

  /// The binding map as a read model (the Models surface's Bindings and
  /// Observe lenses join actors to their cast rows through it).
  Map<String, String> get brainCasts =>
      _bindingsFold?.brainCasts ?? const <String, String>{};

  /// The ordered brain-set read model (the actor card's Brain section
  /// seeds from it — ADR 0143).
  Map<String, List<String>> get brainSets =>
      _bindingsFold?.brainSets ?? const <String, List<String>>{};

  /// The per-actor self-rebind override read model (ADR 0143).
  Map<String, String> get selfBinds =>
      _bindingsFold?.selfBinds ?? const <String, String>{};

  /// The defer predicate's BINDING half: whether this actor is bound in
  /// the daemon's own vocabulary (`cast:` brainRefs and durable
  /// `brainCast` rows) — independent of the daemon being live right
  /// now. The chat's honest-absence row (0f) reads this: a bound actor
  /// with a SLEEPING daemon is exactly when the room must say so.
  bool daemonBoundActor(final ActorProfile actor) {
    if (actor.brainRef.trim().startsWith('cast:')) return true;
    final cast = _bindingsFold?.brainCasts[actor.actorId];
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
  /// actor between app wakes; the defer law must see it). The first
  /// call cold-folds the table; after bind adopted the roster scan,
  /// this reads ONLY the journal tail — a full-table read per journal
  /// event does not scale to a 2000-actor world.
  Future<void> refreshBrainCasts() async {
    final world = _world;
    if (world == null) return;
    try {
      await (_bindingsFold ??= ActorBindingsFold(world.store)).refresh();
    } on Object {
      // An unreadable tail keeps the previous binding view — the next
      // journal event re-reads from the last good cursor.
    }
  }

  /// Thread projections from `thread.list` (newest activity first).
  List<Map<String, Object?>> get threads => List.unmodifiable(_threads);

  /// ADR 0024 / ADR 0146 — the channels (oldest first), LIVE only — an
  /// archived channel leaves this list (its durable thread survives;
  /// the journal is authority). The ONE-projection view: every thread
  /// row declaring `kind: 'channel'` answers from its own fields —
  /// `topic` IS the name, `participants` IS the membership, `threadId`
  /// IS the id (`channelId == threadId`; the secondary registry mint
  /// retires for row-built channels) — and the registry answers only
  /// what the rows don't carry yet (see [registryChannels]). Built in
  /// [refreshThreads] from the same `threadRows()` scan that feeds the
  /// rail, [roomThreads] and the sessions; refreshed on start and
  /// after each [createChannel], [renameChannel], [setChannelIcon] and
  /// [closeChannel].
  List<ChannelInfo> get channels => List.unmodifiable(_channels);

  /// ADR 0146 — the REGISTRY rows (every channel ever registered,
  /// oldest first): the legacy-spelling fallback. A pre-heal legacy row
  /// lists exactly as before, keyed by its registry `channelId`
  /// (retained forever — legacy tabs and references never die); the
  /// per-field fallback (icon/archived for a pre-key row) reads the
  /// same rows. Content only while [kChannelRegistryReadsOn] stands
  /// (the W3 operator flip empties it — flip removes reads, doubles
  /// nothing). Refreshed by [refreshThreads]; a failed fallback scan
  /// keeps the previous cache (a degraded fallback never empties the
  /// lists).
  List<ChannelInfo> get registryChannels =>
      List.unmodifiable(_registryChannels);

  /// ADR 0129 — the project-sealed work threads spawned from LA rooms
  /// (oldest first), cached from [WorkThreadRegistry.list]; refreshed on
  /// start and after each [spawnWorkThread]. The parent room's work card
  /// renders from this link — the order text lives only in the work
  /// thread, never in the parent.
  List<WorkThreadLink> get workThreads => List.unmodifiable(_workThreads);

  /// The work threads spawned from [parentThreadId] (oldest first) —
  /// the parent room's children.
  List<WorkThreadLink> workThreadsOf(final String parentThreadId) => [
    for (final link in _workThreads)
      if (link.parentThreadId == parentThreadId) link,
  ];

  /// The channel registered over [threadId], null for plain threads
  /// (DMs, unregistered groups). LIVE channels only — an archived
  /// channel's thread is never re-presented as its channel.
  ChannelInfo? channelByThreadId(final String threadId) {
    for (final channel in _channels) {
      if (channel.threadId == threadId) return channel;
    }
    return null;
  }

  /// ADR 0146 — the channel-id resolver over BOTH spellings (the
  /// absorption window's law): the legacy registry `channel-…` mint
  /// first (exact channelId match), then the row-built spelling — the
  /// id IS the threadId (exact match covers it: a row-built channel's
  /// `channelId == threadId`). The legacy branch reads the W1 fallback
  /// cache ([registryChannels], populated only while
  /// [kChannelRegistryReadsOn] stands), so after a W3 flip only the
  /// row-built spelling resolves. LIVE channels only — an archived
  /// channel left the lists, and its ids stop resolving with it (the
  /// honest absence; the durable thread survives for the journal).
  /// Sync — no IO (the sync-getter law's resolver half).
  ChannelInfo? channelByAnyId(final String id) {
    if (id.isEmpty) return null;
    for (final channel in _registryChannels) {
      if (!channel.archived && channel.channelId == id) return channel;
    }
    for (final channel in _channels) {
      if (channel.channelId == id || channel.threadId == id) return channel;
    }
    return null;
  }

  /// Wave H — the ONE conversation-surface-id → thread-id resolver
  /// (the pane-instance law's home): a conversation pane renders ITS
  /// OWN thread, and the surface registry's spec plus any activation
  /// lane resolve through this single helper — two visible panes
  /// holding two conversation tabs must never both render the global
  /// [activeThreadId] (the 2026-11-10 defect).
  ///
  /// `channel:<channelId>` resolves through [channelByAnyId] — BOTH id
  /// spellings during the absorption window (the legacy registry mint
  /// first, then the row-built threadId-as-id); `dm:<actorId>` resolves
  /// through [dmThreadOf] (the same lookup [openDm] rides — null until
  /// the DM thread exists); `room:<threadId>` is the thread id itself;
  /// the `conversations` world face — and every non-conversation id —
  /// resolves to null: the no-thread inbox face.
  String? threadIdForSurface(final String surfaceId) {
    if (surfaceId.startsWith('channel:')) {
      return channelByAnyId(surfaceId.substring('channel:'.length))?.threadId;
    }
    if (surfaceId.startsWith('dm:')) {
      return dmThreadOf(surfaceId.substring('dm:'.length));
    }
    if (surfaceId.startsWith('room:')) {
      final threadId = surfaceId.substring('room:'.length);
      return threadId.isEmpty ? null : threadId;
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
  ///
  /// Wave H — [windowStart] is the PANE-INSTANCE read: non-null
  /// returns the whole fold from that index (0 = the complete list),
  /// bypassing the tail bound, so a conversation pane pinned to its
  /// OWN thread slices the identical tail-window/pagination the
  /// active-thread cache keeps ([tailPageSize] + [loadOlderBeats]
  /// arithmetic, per pane). Null keeps today's bounded-tail behavior
  /// byte-for-byte. Still pure: no receipt advance, no notify — a
  /// pinned pane's read never marks its room seen (receipts follow
  /// the service's selection, the focus law).
  Future<List<Map<String, Object?>>> beatsFor(
    final String threadId, {
    final int? windowStart,
  }) async {
    final world = _world;
    if (world == null) return const <Map<String, Object?>>[];
    try {
      final all = await world.projection.beatsOfThread(threadId);
      if (windowStart != null) {
        return all.sublist(windowStart.clamp(0, all.length));
      }
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
  Map<String, Object?>? get activeThread => _threadRowById(_activeThreadId);

  /// The projection row of ONE thread, null when the projection does
  /// not carry it — the lookup [activeThread] and [say]'s
  /// explicit-target lane share (Wave H).
  Map<String, Object?>? _threadRowById(final String? threadId) {
    if (threadId == null) return null;
    for (final thread in _threads) {
      if (thread['threadId'] == threadId) return thread;
    }
    return null;
  }

  final List<Map<String, Object?>> _threads = <Map<String, Object?>>[];
  final List<Map<String, Object?>> _beats = <Map<String, Object?>>[];
  final List<ChannelInfo> _channels = <ChannelInfo>[];

  /// ADR 0146 — the registry rows (every channel ever registered,
  /// oldest first): the legacy-spelling fallback cache behind
  /// [registryChannels], refreshed by the same [refreshThreads] pass
  /// that rebuilds [_channels] (one `scanIndex` round-trip, W1 only —
  /// [kChannelRegistryReadsOn]). A failed scan keeps the previous
  /// cache; the W3 flip empties it.
  final List<ChannelInfo> _registryChannels = <ChannelInfo>[];

  /// The thread ids of LIVE channels, refreshed alongside [_channels]
  /// from the same one-projection pass (row-built + legacy rows, the
  /// merged view's live half). The classifier's channel-wins-over-
  /// dm-shape input. Sync getter law: [roomThreads] and [dmThreadOf]
  /// do no IO, so the knowledge must be cached.
  final Set<String> _liveChannelThreadIds = <String>{};

  /// The thread ids of ARCHIVED channels, refreshed alongside
  /// [_channels] from the same one-projection pass. An archived
  /// channel's thread stays open in the journal (closing never
  /// destroys), so without this set [roomThreads] would resurrect it
  /// as a plain "room" the moment it leaves the live channel list.
  /// Sync getter law: [roomThreads] does no IO, so the knowledge must
  /// be cached.
  final Set<String> _archivedChannelThreadIds = <String>{};
  final List<WorkThreadLink> _workThreads = <WorkThreadLink>[];
  final Map<String, String> _beatPreviews = <String, String>{};
  String _previewSignature = '';
  bool _sending = false;
  final Map<String, int> _pollCursor = <String, int>{};

  /// ADR 0129 — per-reuse-key spawn serialization:
  /// `'$parentThreadId|$projectRoot'` → the tail of the spawn chain. A
  /// double-send chains behind the in-flight spawn instead of racing it,
  /// so one work thread per scope is a law, not a hope. An entry drops
  /// when its tail settles.
  final Map<String, Future<WorkThreadSpawn>> _spawnChains =
      <String, Future<WorkThreadSpawn>>{};

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
  ///
  /// BOUNDED (the live-drive finding, 2026-11-23): a start whose realm
  /// write leg never settles (a journal write lost against concurrent
  /// live writers — seats + daemon on the same control store) used to
  /// hold `_starting` forever, poisoning EVERY verb for the whole app
  /// run. Now one start gets a bounded window; on timeout the gate
  /// names `realm_start_timeout`, releases, and a later verb retries
  /// fresh. A late success after a timeout only improves state — every
  /// start leg is idempotent.
  Future<void> ensureReady() async {
    if (_ready || _disposed || !isSupported) return;
    await (_starting ??= _start().timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        if (!_ready) {
          _error = 'realm_start_timeout';
          _starting = null;
        }
      },
    ));
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
      // The bindings fold adopts the SAME scan as its cold fold: one
      // table read at bind, incremental journal-tail reads after (the
      // TailFold law — the refresh path never re-scans per event).
      _bindingsFold = ActorBindingsFold(world.store)..adoptScan(records.values);
      for (final record in records.values) {
        final actorId = record['actorId'];
        if (actorId is! String || actorId.isEmpty) continue;
        // A RETIRED row keeps its history and stops being driven
        // (ADR 0120): never re-adopted as a live identity — the actor
        // surface names the retirement verbatim instead.
        if (record['retiredAt'] is String) {
          _retiredRows[actorId] = Map<String, Object?>.from(record);
          continue;
        }
        _adoptLiveRecord(record);
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
        // Late-bound through the field: the shell wires it after this
        // construction (the subscription actors' mounting pass).
        resolveSubscription: (final providerId, final model) =>
            resolveSubscription?.call(providerId, model),
        createAcpWorker: (final actor) => createAcpWorker?.call(actor),
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
      // ADR 0146 W2 — the channel heal: the registry's row fields
      // (`kind: 'channel'`, `icon`, `archived`) backfill onto the
      // pre-window thread rows, so the one-projection reads below see
      // every channel row-shaped. Idempotent per-field — a second call
      // heals 0 — and a failed heal is logged (never thrown out of
      // boot); the next boot retries it.
      try {
        await registry.migrateIntoRows();
      } on Object catch (error) {
        _error = 'channel_row_heal_failed: $error';
      }
      _workRegistry = WorkThreadRegistry(store: world.store);
      // ADR 0146 W2/W3 — the work-thread heal: the registry links'
      // `parentThreadId` backfill onto the pre-window work rows, so
      // the row reads below (the reuse key, the parent-room cards)
      // see every work row link-shaped. Same idempotence + honest
      // failure law as the channel heal above.
      final workRegistry = _workRegistry;
      if (workRegistry != null) {
        try {
          await workRegistry.migrateIntoRows();
        } on Object catch (error) {
          _error = 'work_row_heal_failed: $error';
        }
      }
      await _refreshWorkThreads();
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

  /// The subscription providers changed (the shell's listener on the
  /// chatgpt/grok actor stores): the `subscription:`-brained bots'
  /// resolvers now answer differently. Plain [syncBots] would keep
  /// those loops (an unchanged brainRef is not a material change), so
  /// they are stopped first — syncBots rebuilds them, and the next
  /// generation re-resolves against the fresh provider state (the
  /// client factory rides generate time). RECONSTRUCTED 2026-11-18
  /// after a parallel lane's rewrite lost the original member
  /// (app_shell's wiring is the contract; the owning lane may refine).
  void noteSubscriptionProvidersChanged() {
    final bots = _bots;
    if (bots == null) return;
    for (final actor in _roster?.all ?? const <ActorProfile>[]) {
      if (actor.brainRef.trim().startsWith('subscription:')) {
        bots.stopBot(actor.actorId);
      }
    }
    syncBots();
  }

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
    String? avatar,
    List<String>? brainSet,
    String? selfBind,
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
        avatar: avatar,
        brainSet: brainSet,
        selfBind: selfBind,
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

  /// One durable record's LIVE adoption — the boot scan's per-row body,
  /// extracted for [reviveActor]: derives the editable brainRef (the
  /// `cast:` synthesis included — ACTOR EQUALITY, owner law 2026-11-16:
  /// daemon-minted rows carrying only `brainCast` land editable and
  /// DM-able; a row with neither brain nor cast still lands with an
  /// EMPTY brainRef, the editor being exactly how it gets a brain) and
  /// upserts the roster identity when absent.
  void _adoptLiveRecord(final Map<String, Object?> record) {
    final roster = _roster;
    if (roster == null) return;
    final actorId = record['actorId'];
    if (actorId is! String || actorId.isEmpty) return;
    final brain = record['brainRef'] as String?;
    final cast = record['brainCast'] as String?;
    final brainRef = (brain != null && brain.isNotEmpty)
        ? brain
        : (cast != null && cast.isNotEmpty ? 'cast:$cast' : '');
    if (roster.get(actorId) != null) return;
    roster.upsert(
      ActorProfile(
        actorId: actorId,
        displayName: record['displayName'] as String? ?? actorId,
        kind: ActorKind.values.firstWhere(
          (kind) => kind.name == record['actorKind'],
          orElse: () => ActorKind.model,
        ),
        brainRef: brainRef,
        role: record['role'] as String? ?? '',
        systemPrompt: record['systemPrompt'] as String? ?? '',
        avatar: record['avatar'] as String?,
      ),
    );
  }

  void removeActor(String actorId) {
    final roster = _roster;
    if (roster == null) return;
    removeActorIdentity(roster, actorId);
    _bots?.stopBot(actorId);
    syncBots();
  }

  /// Retires the DURABLE world row through the host's own verb
  /// (ADR 0120: the row keeps its history and stops being driven; a
  /// fresh ensure revives it). [removeActor] is the roster projection
  /// half; the actor surface calls both behind one confirm. A bounce
  /// renders verbatim — the retire refusal names its input.
  Future<Map<String, Object?>> retireActor(final String actorId) async {
    final world = _world;
    if (world == null) {
      return const <String, Object?>{'ok': false, 'bounce': 'realm_not_ready'};
    }
    try {
      return await retireRealmActor(world.store, actorId: actorId);
    } on Object catch (error) {
      return <String, Object?>{'ok': false, 'bounce': '$error'};
    }
  }

  /// Revives a RETIRED durable row — the UI face of ADR 0120's revival
  /// law ("a fresh ensure revives"): the retirement marks come OFF the
  /// row (the harness ensure's own revival strips `retiredAt`; the
  /// retireReason goes with it — the reason no longer applies to a live
  /// identity), the identity re-adopts into the roster
  /// ([_adoptLiveRecord]), and the bot loop rebuilds ([syncBots]). The
  /// receipt shape mirrors [retireActor]: `ok` plus a verbatim `bounce`
  /// on refusal (`realm_not_ready`, `actor_unknown`, `actor_not_retired`).
  Future<Map<String, Object?>> reviveActor(final String actorId) async {
    final world = _world;
    if (world == null) {
      return const <String, Object?>{'ok': false, 'bounce': 'realm_not_ready'};
    }
    final id = actorId.trim();
    try {
      final receipt = await world.store.transact((tx) {
        final existing = tx.get('realm_actors', id);
        if (existing == null) {
          return <String, Object?>{
            'ok': false,
            'bounce': 'actor_unknown: actor "$id" has no durable row',
          };
        }
        if (existing['retiredAt'] is! String) {
          return <String, Object?>{
            'ok': false,
            'bounce': 'actor_not_retired: actor "$id" is not retired',
          };
        }
        tx.put(
          'realm_actors',
          id,
          <String, Object?>{...existing}
            ..remove('retiredAt')
            ..remove('retireReason'),
        );
        return <String, Object?>{'ok': true, 'actorId': id};
      });
      if (receipt['ok'] != true) return receipt;
      _retiredRows.remove(id);
      final record = await world.store.read('realm_actors', id);
      if (record != null) _adoptLiveRecord(record);
      syncBots();
      notifyListeners();
      return receipt;
    } on Object catch (error) {
      return <String, Object?>{'ok': false, 'bounce': '$error'};
    }
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
  ///
  /// ADR 0146 — the ONE-projection pass: the same `threadRows()` scan
  /// feeds the channel view too ([_refreshChannelView] — the rail's
  /// channel list, the classifier's live/archived sets and the legacy
  /// fallback cache), so the second collection read no longer rides
  /// every boot/refresh path as its own projection.
  Future<void> refreshThreads() async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return;
    unawaited(refreshBrainCasts());
    await _refreshRegistryFallback();
    try {
      final projection = world.projection;
      final rows = await projection.threadRows();
      _refreshChannelView(rows.values);
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
      enriched.sort((a, b) => activityOf(b).compareTo(activityOf(a)));
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
  ///
  /// ADR 0145 — [kind] DECLARES the row's kind when non-null (exactly
  /// `dm` | `channel` | `session` — the host validates and refuses
  /// `kind_work_is_derived` / `kind_unknown`); null opens an UNTYPED
  /// thread: the row carries no `kind` key (absent means infer,
  /// forever) and ad-hoc human threads stay organic rooms by shape.
  Future<void> startThread({
    required String topic,
    List<String> participants = const <String>[],
    String? kind,
    String? parentThreadId,
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
        kind: kind,
        // ADR 0146 W3 — a conversational child's parent link rides the
        // row (absent means no link, never null).
        parentThreadId: parentThreadId,
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
  ///
  /// A DM is a PLAIN two-member thread. A thread that belongs to another
  /// surface is never a DM-reuse key, even when it carries the same two
  /// participants: a channel-backed room (live or archived — the same
  /// skip [classifyThread] makes) or a project-sealed work thread (ADR
  /// 0129). Without this, a leftover machine-minted room shadows the DM
  /// lookup and the People panel DM button lands in it (seen live
  /// 2026-11-16: DM on cache-probe opened `dogfood-1794173922369`, a
  /// dogfood-leg channel). Archiving alone cannot fix the class — an
  /// archived channel's thread stays open in the journal, so the skip
  /// must ride [_archivedChannelThreadIds] exactly like [classifyThread].
  ///
  /// ADR 0145 — DECLARED beats inference: a row carrying `kind: 'dm'`
  /// IS the dm — the fast path skips the channel/work/archive skips
  /// entirely (the classifier never touches the sets for a declared
  /// kind either). Any OTHER declared kind (`channel` / `session`) is
  /// by law that surface, never a dm slot. Untyped rows keep today's
  /// exact skip behavior (the absorption law: absent means infer,
  /// forever). The exact participant pair and `!closed` hold on EVERY
  /// path.
  String? dmThreadOf(final String actorId) {
    final human = humanActorId;
    if (human == null || actorId == human) return null;
    final workThreadIds = {for (final link in _workThreads) link.workThreadId};
    for (final thread in _threads) {
      if (thread['closed'] == true) continue;
      final threadId = '${thread['threadId'] ?? ''}';
      final declared = thread['kind'];
      final isDeclaredDm = declared == 'dm';
      if (!isDeclaredDm) {
        // A declared non-dm row is that other surface; an untyped row
        // keeps the exact pre-ADR 0145 skips.
        if (declared != null) continue;
        if (channelByThreadId(threadId) != null ||
            _archivedChannelThreadIds.contains(threadId) ||
            workThreadIds.contains(threadId)) {
          continue;
        }
      }
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

  /// The topic of a known thread, null when the projection does not
  /// carry it (the `room:` tab title's source — honest raw-id fallback
  /// upstream).
  String? topicOf(final String threadId) {
    for (final thread in _threads) {
      if (thread['threadId'] == threadId) return thread['topic'] as String?;
    }
    return null;
  }

  /// Whether the projection knows this thread (the boot-restore gate
  /// for `room:` tabs — a ghost id never re-selects).
  bool knowsThread(final String threadId) =>
      _threads.any((thread) => thread['threadId'] == threadId);

  /// The WATCHABLE ROOMS (1d): open threads that are neither a DM slot
  /// nor a channel — actor↔actor rooms and plain group threads. An
  /// ARCHIVED channel's thread never resurfaces here as a room (the
  /// channel left the lists; its thread stays in the journal). The
  /// human watches them like any room and joins by addressing (the
  /// mention grammar already exists); the picker and palette list them.
  ///
  /// ADR 0145 — DECLARED `session` threads (machine-life rooms, the
  /// smokes and dogfood runs) are watchable too: owner decision
  /// 2026-11-16, a session is a room with advanced placement, never a
  /// dm and never hidden. Project-SEALED threads (the DERIVED `work`)
  /// leave the watchable set — their projection is the parent's work
  /// card, not this list.
  ///
  /// The kind derivation is the harness spaces layer's [classifyThread]
  /// (harness ADR 0144/0145) — LA classifies with the same words the
  /// agents do; this getter is only the projection over it. The row's
  /// declared `kind` and its project seal ride in verbatim; the channel
  /// sets come from the cached one-scan projections (sync getter law:
  /// no IO here).
  List<Map<String, Object?>> get roomThreads {
    final human = humanActorId;
    ConversationKind kindOf(final Map<String, Object?> thread) =>
        classifyThread(
          threadId: '${thread['threadId'] ?? ''}',
          participants: (thread['participants'] as List? ?? const <Object?>[])
              .cast<String>()
              .toSet(),
          closed: thread['closed'] == true,
          humanActorId: human,
          kind: thread['kind'] as String?,
          projectId: thread['projectId'] as String?,
          liveChannelThreadIds: _liveChannelThreadIds,
          archivedChannelThreadIds: _archivedChannelThreadIds,
        );
    final rooms = <Map<String, Object?>>[];
    for (final thread in _threads) {
      if (thread['closed'] == true) continue;
      final kind = kindOf(thread);
      if (kind == ConversationKind.room || kind == ConversationKind.session) {
        rooms.add(thread);
      }
    }
    return rooms;
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
    // ADR 0145 — the DM declares itself: the fresh thread opens with
    // kind 'dm' on its row (reused threads already carry theirs).
    await startThread(
      topic: displayName,
      participants: <String>[actorId],
      kind: 'dm',
    );
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
    String? openedThreadId;
    try {
      final opened = await world.conversation().open(
        actor: human,
        topic: trimmed,
        participants: members,
        // Realm-sealed like every LA room (see startThread).
        realmSealed: true,
        // ADR 0145 — the pairing invariant: the thread row carries the
        // declared kind in the SAME call that (below) writes the
        // registry row — the harness openChannel's ordering, open then
        // registry write.
        kind: 'channel',
      );
      final threadId = opened['threadId']! as String;
      openedThreadId = threadId;
      // ADR 0146 W3 — the mirror write rides the flip: reads off → no
      // registry row (the row IS the channel; its id IS the threadId)
      // and the ChannelInfo builds from the opened row. Reads on → the
      // W1 registry mirror (its mint is the legacy spelling).
      final ChannelInfo channel;
      if (kChannelRegistryReadsOn) {
        channel = await registry.create(
          name: trimmed,
          threadId: threadId,
          memberIds: members,
        );
      } else {
        final row = await world.store.read('threads', threadId);
        channel = ChannelInfo(
          channelId: threadId,
          name: trimmed,
          threadId: threadId,
          memberIds: members,
          createdAt: row?['createdAt'] is String
              ? row!['createdAt']! as String
              : DateTime.now().toUtc().toIso8601String(),
        );
      }
      _activeThreadId = threadId;
      _beats.clear();
      _windowStart = null;
      // ADR 0146 — the one-projection refresh: the channel view (the
      // row-built list), the classifier sets and the registry fallback
      // cache all rebuild from the same threadRows() scan.
      await refreshThreads();
      return channel;
    } on Object catch (error) {
      // The pairing invariant's honest half: once the thread OPENED,
      // its row already carries kind 'channel' — the classifier reads
      // the row, so the thread stays an honestly-classified channel
      // even with no registry row yet. Surface that exact state
      // verbatim instead of pretending the channel exists.
      _error = openedThreadId == null
          ? error.toString()
          : 'channel_registry_write_failed:$openedThreadId ($error)';
      notifyListeners();
      return null;
    }
  }

  /// ADR 0145 — opens a DECLARED session thread (machine-life room:
  /// the smokes and dogfood runs, actor-experiments tooling): realm-
  /// sealed, `kind: 'session'` on the row, the label in the topic.
  /// Sessions are watchable rooms with advanced placement (owner
  /// decision 2026-11-16) — never dms, never channels, no registry row.
  /// Returns the open result verbatim (its `threadId` is the smoke's
  /// handle); null on a not-ready service or a refusal, with the named
  /// error surfaced.
  Future<Map<String, Object?>?> openSession(
    final String label, {
    final List<String> memberIds = const <String>[],
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return null;
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      _error = 'session_label_missing';
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
        // Realm-sealed like every LA room (see startThread) — a session
        // is conversation, never a project sandbox.
        realmSealed: true,
        kind: 'session',
      );
      _activeThreadId = opened['threadId']! as String;
      _beats.clear();
      _windowStart = null;
      await refreshThreads();
      return opened;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return null;
    }
  }

  /// Renames one channel — the SAME policy lane as [createChannel]:
  /// an empty trimmed name refuses with `channel_name_empty`, a name
  /// duplicating any OTHER live channel (case-insensitive) refuses with
  /// `channel_name_taken`, and success refreshes the projections and
  /// notifies. False on refusal, an unknown [channelId] or a not-ready
  /// service — the honest-refusal law, never a throw.
  ///
  /// ADR 0146 — rename = topic edit (one fact, one write): `topic` IS
  /// the channel name, so the thread row's topic is the write; the
  /// registry mirror row over the same thread stays in sync until W3
  /// (the dual-write law). [channelId] resolves BOTH spellings
  /// ([channelByAnyId]).
  Future<bool> renameChannel(final String channelId, final String name) async {
    final world = _world;
    final registry = _channelRegistry;
    final human = _human;
    if (world == null || registry == null || human == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      _error = 'channel_name_empty';
      notifyListeners();
      return false;
    }
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    final taken = _channels.any(
      (final candidate) =>
          candidate.threadId != channel.threadId &&
          candidate.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (taken) {
      _error = 'channel_name_taken';
      notifyListeners();
      return false;
    }
    try {
      // ADR 0147 — the rename rides the harness `setChannelTopic` verb
      // (topic IS the name, ADR 0146): one law for the naming policy
      // AND the manage gate (without an `access` key any participant
      // renames; `manage: 'owners'` narrows to the owners). The old
      // direct topic write bypassed every gate — an app-side hole in
      // the world's law.
      await world.conversation().setChannelTopic(
        actor: human,
        threadId: channel.threadId,
        name: trimmed,
      );
      final mirror = _registryByThread(channel.threadId);
      if (mirror != null) {
        await registry.rename(channelId: mirror.channelId, name: trimmed);
      }
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Closes one channel: the channel is ARCHIVED and leaves [channels]
  /// (and [roomThreads]); when its thread is the active one, the
  /// selection is cleared. LAW: closing never destroys anything — the
  /// journal is authority, so the durable thread and every beat in it
  /// survive untouched. False on a refusal or a not-ready service.
  ///
  /// ADR 0146 — the archive rides the harness `archiveChannel` verb:
  /// the thread row's `archived: true` flips IN THE SAME TRANSACTION
  /// as the registry row's (no half states), BOTH id spellings resolve
  /// (the legacy registry mint first, then the row-built threadId-as-
  /// id), re-archiving an archived channel stays honest idempotence,
  /// an id naming an existing NON-channel thread refuses
  /// `thread_not_kind_channel` and an unknown id refuses
  /// `channel_not_found` — both surfaced verbatim (the honest-refusal
  /// law).
  Future<bool> closeChannel(final String channelId) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    // Resolved BEFORE the flip (the selection release needs the thread
    // id); an unknown id rides the verb's honest `channel_not_found`.
    final channel = channelByAnyId(channelId);
    try {
      await world.conversation().archiveChannel(
        actor: human,
        channelId: channelId,
      );
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
    if (channel != null && _activeThreadId == channel.threadId) {
      clearActiveThread();
    }
    await refreshThreads();
    return true;
  }

  /// Sets (or clears, with null/blank) a channel's user-chosen icon
  /// glyph — ADR 0146: the mark rides the thread ROW (a present icon
  /// writes the key; a null CLEAR removes the key — absent means the
  /// default '#' mark, never `'icon': null`), with the registry mirror
  /// row kept in sync until W3. [channels] re-projects + notifies so
  /// rows and tab leadings follow. [channelId] resolves BOTH spellings
  /// ([channelByAnyId]). False on an unknown [channelId] or a
  /// not-ready service.
  Future<bool> setChannelIcon({
    required final String channelId,
    required final String? icon,
  }) async {
    final world = _world;
    final registry = _channelRegistry;
    if (world == null || registry == null) return false;
    final trimmed = icon?.trim();
    final value = (trimmed?.isEmpty ?? true) ? null : trimmed;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    try {
      await world.store.transact((tx) {
        final thread = tx.get('threads', channel.threadId);
        if (thread == null) return;
        final next = <String, Object?>{...thread};
        // Never write null for an absent-means-default key.
        if (value == null) {
          next.remove('icon');
        } else {
          next['icon'] = value;
        }
        tx.put('threads', channel.threadId, next);
      });
      final mirror = _registryByThread(channel.threadId);
      if (mirror != null) {
        await registry.setIcon(channelId: mirror.channelId, icon: value);
      }
      await refreshThreads();
      return true;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Re-scans the durable work-thread links (the child-thread lane
  /// writes them through the registry from the chat surface; the
  /// projection follows here). Public so a widget-written link becomes
  /// visible to [workThreadsOf] without waiting for the next spawn.
  Future<void> refreshWorkThreads() => _refreshWorkThreads();

  /// The first-run seed channel name ([ensureSeededChannel]).
  static const String seededChannelName = 'general';

  /// The seed's policy input: the shell boots with the seed ON (a fresh
  /// world lands in [#seededChannelName] — the owner's first-entry law),
  /// and hermetic surfaces that want the EMPTY-world face (tests of the
  /// landing inbox, kiosk lanes) turn it off before the shell boots.
  /// A policy input like [resolveCastRung], never a debug back door.
  bool firstRunSeedEnabled = true;

  /// The shell's once-at-boot seed: when the registry has NEVER had a
  /// channel (`list(includeArchived: true)` is empty), create
  /// [seededChannelName] through the ordinary [createChannel] lane
  /// (human member only; the channel is selected on success). LAW: an
  /// archived seed is NEVER resurrected — a world whose only channel
  /// was closed stays empty. Idempotent, and never throws into the
  /// shell (a failed seed is an honest absence, not a boot crash).
  /// Deliberately NOT part of [ensureReady]: hermetic fixtures must
  /// never seed implicitly.
  Future<void> ensureSeededChannel() async {
    if (!firstRunSeedEnabled) return;
    try {
      await ensureReady();
      final world = _world;
      // ADR 0146 W3 — the seed's "never had a channel" answer reads
      // the ROW projection (any kind:channel row, live OR archived —
      // an archived seed is never resurrected); the registry scan
      // stays the W1 path only.
      if (kChannelRegistryReadsOn) {
        final registry = _channelRegistry;
        if (registry == null) return;
        final all = await registry.list(includeArchived: true);
        if (all.isNotEmpty) return;
      } else {
        if (world == null) return;
        final rows = await world.projection.threadRows();
        if (rows.values.any((final row) => row['kind'] == 'channel')) {
          return;
        }
      }
      await createChannel(seededChannelName);
    } on Object {
      // Boot seed law: never throw into the shell.
    }
  }

  /// Selects the thread the named channel talks in (no-op when
  /// unknown). ADR 0146 — BOTH id spellings resolve
  /// ([channelByAnyId]).
  void selectChannel(final String channelId) {
    final channel = channelByAnyId(channelId);
    if (channel != null) selectThread(channel.threadId);
  }

  /// ADR 0146 — the W1 fallback read: ONE [ChannelRegistry.scanIndex]
  /// round-trip feeds the legacy-spelling resolution and the channel
  /// view's per-field fallback. Gated on [kChannelRegistryReadsOn] (the
  /// operator flip empties the cache and stops the read — flip doubles
  /// nothing, it only removes reads). A failed scan keeps the previous
  /// cache: a degraded fallback never empties the lists, and the row
  /// projection below is the preferred truth anyway.
  Future<void> _refreshRegistryFallback() async {
    final registry = _channelRegistry;
    if (registry == null) {
      _registryChannels.clear();
      return;
    }
    if (!kChannelRegistryReadsOn) {
      _registryChannels.clear();
      return;
    }
    try {
      final index = await registry.scanIndex();
      _registryChannels
        ..clear()
        ..addAll(index.all);
    } on Object {
      // The fallback degraded; the row projection still lands.
    }
  }

  /// The registry row over [threadId] (first — oldest — wins, the
  /// scanIndex law), null when none: the channel view's per-field
  /// fallback and the verbs' registry mirror lookup.
  ChannelInfo? _registryByThread(final String threadId) {
    for (final channel in _registryChannels) {
      if (channel.threadId == threadId) return channel;
    }
    return null;
  }

  /// ADR 0146 — the ONE-projection channel view, built inside
  /// [refreshThreads] from the same `threadRows()` scan that feeds the
  /// rail: every thread row DECLARING `kind: 'channel'` answers from
  /// its own fields — `topic` IS the name, `participants` IS the
  /// membership, `threadId` IS the id (`channelId == threadId`; the
  /// secondary registry mint retires for row-built channels, absorbed
  /// by the resolvers) — with the registry answering ONLY what the row
  /// doesn't carry yet (a pre-key `icon`/`archived`, pre-heal). The
  /// legacy branch (registry rows whose thread rows predate `kind`)
  /// lists exactly as before, keyed by its registry id — retained
  /// forever. One merged, `createdAt`-ordered list feeds [channels],
  /// the classifier's live/archived thread-id sets (sync getter law:
  /// no IO there) at once.
  void _refreshChannelView(final Iterable<Map<String, Object?>> rows) {
    final channels = <ChannelInfo>[];
    final rowChannelThreadIds = <String>{};
    for (final row in rows) {
      if (row['kind'] != 'channel') continue;
      final threadId = '${row['threadId'] ?? ''}';
      if (threadId.isEmpty) continue;
      rowChannelThreadIds.add(threadId);
      final fallback = _registryByThread(threadId);
      final topic = row['topic'];
      // ADR 0146 W3 — the legacy mint is preserved ON the row (the
      // heal carried it across the flip), so the both-spelling
      // resolver law survives the emptied fallback cache: a healed
      // legacy row answers its `channel-…` id; a row-built channel's
      // id IS the threadId.
      final channelId = row['channelId'] is String
          ? row['channelId']! as String
          : threadId;
      channels.add(
        ChannelInfo(
          channelId: channelId,
          name: topic is String && topic.isNotEmpty ? topic : threadId,
          threadId: threadId,
          memberIds: <String>[
            for (final id in row['participants'] as List? ?? const <Object?>[])
              if (id is String && id.isNotEmpty) id,
          ]..sort(),
          createdAt: row['createdAt'] is String
              ? row['createdAt']! as String
              : '',
          // Per-field fallback law: a row carrying the key answers from
          // the row; a pre-key row reads its registry row (pre-heal).
          archived: row.containsKey('archived')
              ? row['archived'] == true
              : (fallback?.archived ?? false),
          icon: row['icon'] is String ? row['icon']! as String : fallback?.icon,
        ),
      );
    }
    for (final channel in _registryChannels) {
      if (rowChannelThreadIds.contains(channel.threadId)) continue;
      channels.add(channel);
    }
    channels.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // LIVE channels only — an archived channel leaves the list (the
    // same law the registry scan's live list held); its thread id lands
    // in the archived set ([roomThreads]'s resurrection guard).
    _channels
      ..clear()
      ..addAll(<ChannelInfo>[
        for (final channel in channels)
          if (!channel.archived) channel,
      ]);
    _liveChannelThreadIds
      ..clear()
      ..addAll(<String>{
        for (final channel in channels)
          if (!channel.archived) channel.threadId,
      });
    _archivedChannelThreadIds
      ..clear()
      ..addAll(<String>{
        for (final channel in channels)
          if (channel.archived) channel.threadId,
      });
  }

  Future<void> _refreshWorkThreads() async {
    final registry = _workRegistry;
    if (registry == null) return;
    try {
      final List<WorkThreadLink> links;
      // ADR 0146 W3 — reads off: the links build from the row
      // projection (`parentThreadId` + the seal ride the row); the
      // registry scan stays a migration-time path only. Same
      // createdAt order either way.
      if (kWorkThreadRegistryReadsOn) {
        links = await registry.list();
      } else {
        final rows =
            await _world?.projection.threadRows() ??
            const <String, Map<String, Object?>>{};
        links = <WorkThreadLink>[];
        for (final row in rows.values) {
          final parent = row['parentThreadId'];
          // A conversational child carries the parent link with NO
          // seal (the honest empty root); a work thread carries the
          // project seal. Both are links — the parent key is the law.
          if (parent is! String) continue;
          final scope = row['projectId'] is String
              ? row['projectId']! as String
              : '';
          final threadId = '${row['threadId'] ?? ''}';
          if (threadId.isEmpty) continue;
          links.add(
            _workLinkFromRow(
              row,
              workThreadId: threadId,
              parentThreadId: parent,
              projectRoot: scope,
              fallbackName: scope.isEmpty
                  ? (row['topic'] is String &&
                            (row['topic']! as String).isNotEmpty
                        ? row['topic']! as String
                        : threadId)
                  : _defaultWorkThreadName(scope),
            ),
          );
        }
        links.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
      _workThreads
        ..clear()
        ..addAll(links);
    } on Object catch (error) {
      _error = error.toString();
    }
  }

  // ---- work-thread verbs (ADR 0129: the delegation seam) ----

  /// Spawns (or reuses) the project-sealed work thread for a work order
  /// sent from [parentThreadId] targeting [projectRoot], and forwards
  /// [orderText] into it as ONE addressed beat.
  ///
  /// The seal IS the sandbox: the daemon dispatch reads the work
  /// thread's `projectId` as the actor's filesystem workRoot, so
  /// delegated work lands in the repo the order named — never in the
  /// daemon's own project (the projectless realm-sealed room's
  /// wrong-repo fallback). ONE thread per (parentThreadId, projectRoot)
  /// — the reuse key: later orders for the same scope forward into the
  /// same thread, never a new thread per beat. Spawns serialize per
  /// reuse key ([_spawnChains]), so a double-send cannot mint two.
  ///
  /// LA's human authority is scoped to the app-support world
  /// ([RealmWorld.root]), so sealing to a real repo rides ADR 0129's
  /// grant check: without the repo in the human's durable grant set the
  /// harness refuses `project_not_granted`, and this method returns it
  /// as a TYPED [WorkThreadSpawn] refusal carrying the current grants —
  /// the honest-refusal law, never an escaping exception, so the UI can
  /// offer a one-tap [grantAccess].
  ///
  /// The parent room does NOT receive the order text; the registry link
  /// ([workThreadsOf]) is what its work card renders. The work thread is
  /// never auto-selected: the human stays in the parent room.
  Future<WorkThreadSpawn> spawnWorkThread({
    required final String parentThreadId,
    required final String projectRoot,
    final List<String> memberIds = const <String>[],
    final String? orderText,
    final String? topic,
  }) {
    final root = projectRoot.trim();
    final key = '$parentThreadId|$root';
    final prior = _spawnChains[key];
    final next = prior == null
        ? _spawnWorkThread(
            parentThreadId: parentThreadId,
            projectRoot: root,
            memberIds: memberIds,
            orderText: orderText,
            topic: topic,
          )
        : prior.then(
            (_) => _spawnWorkThread(
              parentThreadId: parentThreadId,
              projectRoot: root,
              memberIds: memberIds,
              orderText: orderText,
              topic: topic,
            ),
          );
    _spawnChains[key] = next;
    unawaited(
      next.whenComplete(() {
        if (identical(_spawnChains[key], next)) {
          // Map.remove hands back the removed future — this is chain
          // bookkeeping, not an awaitable step (and awaiting `next`
          // from inside its own completion would deadlock).
          final _ = _spawnChains.remove(key);
        }
      }),
    );
    return next;
  }

  Future<WorkThreadSpawn> _spawnWorkThread({
    required final String parentThreadId,
    required final String projectRoot,
    required final List<String> memberIds,
    final String? orderText,
    final String? topic,
  }) async {
    final world = _world;
    final human = _human;
    final registry = _workRegistry;
    if (world == null || human == null || registry == null) {
      return WorkThreadSpawn(
        refusal: 'realm_not_ready',
        requestedProject: projectRoot,
        message: 'the world chat service is not ready',
      );
    }
    if (projectRoot.isEmpty) {
      return const WorkThreadSpawn(
        refusal: 'project_root_missing',
        message: 'a work order names the workspace root it targets',
      );
    }
    // The link points at the parent forever — an unknown parent is a
    // named refusal, never a guess.
    final parent = parentThreadId.trim();
    final parentRow = await world.store.read('threads', parent);
    if (parentRow == null) {
      return WorkThreadSpawn(
        refusal: 'parent_thread_missing',
        requestedProject: projectRoot,
        message: 'no thread named $parentThreadId',
      );
    }
    final members = [
      for (final id in memberIds)
        if (id.trim().isNotEmpty && id.trim() != human.actor) id.trim(),
    ];
    // ADR 0146 W3 — the reuse key rides the flip: reads on → the
    // registry's `byKey` (the W1 law); reads off → the ROW reuse key
    // (a work row answers `parentThreadId` + `projectId` — the seal
    // IS the scope). The heal at boot carried the legacy links across.
    var link = kWorkThreadRegistryReadsOn
        ? await registry.byKey(parentThreadId: parent, projectRoot: projectRoot)
        : await _workLinkFromRows(parent, projectRoot);
    final reused = link != null;
    String? refusal;
    var grants = const <String>[];
    String? message;
    if (link == null) {
      final trimmedTopic = topic?.trim() ?? '';
      final name = trimmedTopic.isEmpty
          ? _defaultWorkThreadName(projectRoot)
          : trimmedTopic;
      try {
        final opened = await world.conversation().open(
          actor: human,
          topic: name,
          participants: members,
          // ADR 0129 — project-sealed, NOT realm-sealed (the two are
          // mutually exclusive): the seal is the daemon actor's sandbox
          // and minting it requires the durable grant.
          projectId: projectRoot,
          // ADR 0146 — the parent link rides the SAME open() call as
          // the row (`parentThreadId` on the work row; absent means no
          // link, never null). The registry link below stays W1-only —
          // reads off, the row IS the link.
          parentThreadId: parent,
        );
        final workThreadId = opened['threadId']! as String;
        link = kWorkThreadRegistryReadsOn
            ? await registry.create(
                workThreadId: workThreadId,
                parentThreadId: parent,
                projectRoot: projectRoot,
                name: name,
                createdBy: human.actor,
              )
            : _workLinkFromRow(
                await world.store.read('threads', workThreadId) ??
                    const <String, Object?>{},
                workThreadId: workThreadId,
                parentThreadId: parent,
                projectRoot: projectRoot,
                fallbackName: name,
              );
      } on DurableRealmRefusal catch (refused) {
        // The honest-refusal law: `project_not_granted` lands as a typed
        // result carrying the current grants — never an escape, never a
        // guess around the absence.
        refusal = refused.code;
        grants = (refused.detail?['grants'] as List? ?? const <Object?>[])
            .cast<String>();
        message =
            'the human authority lacks the durable grant for '
            '$projectRoot (ADR 0129)';
      } on Object catch (error) {
        refusal = 'work_thread_open_failed';
        message = error.toString();
      }
    }
    // The forward: ONE human beat in the WORK thread, addressed to the
    // members (the daemon groups a thread's pending addressed beats into
    // one dispatch, so one order = one beat). Fresh AND reused threads
    // forward — reuse changes where the thread comes from, never
    // whether the order lands.
    int? orderBeat;
    final order = orderText?.trim() ?? '';
    final workThread = link;
    if (workThread != null && order.isNotEmpty) {
      try {
        final said = await world.conversation().say(
          actor: human,
          threadId: workThread.workThreadId,
          text: order,
          addressedTo: members,
        );
        orderBeat = said['beat']! as int;
      } on DurableRealmRefusal catch (refused) {
        refusal ??= refused.code;
        message ??= 'the work thread exists; the order beat refused';
      } on Object catch (error) {
        refusal ??= 'order_forward_failed';
        message ??= error.toString();
      }
    }
    await _refreshWorkThreads();
    // The granted seal makes the work thread visible to the human's own
    // thread projection (ADR 0121 visibility law) — refresh so the
    // parent room's work card has both halves immediately.
    await refreshThreads();
    return WorkThreadSpawn(
      workThread: workThread,
      reused: reused,
      orderBeat: orderBeat,
      refusal: refusal,
      grants: grants,
      requestedProject: refusal == null ? null : projectRoot,
      message: message,
    );
  }

  /// ADR 0146 W3 — the row-built work link (reads off): the row IS
  /// the link — `workThreadId` = the threadId, the scope = the seal
  /// (`projectId`), the card name = the topic (the open wrote it;
  /// [fallbackName] covers a blank one), the parent = the row's
  /// `parentThreadId` (the boot heal carried legacy links across).
  WorkThreadLink _workLinkFromRow(
    final Map<String, Object?> row, {
    required final String workThreadId,
    required final String parentThreadId,
    required final String projectRoot,
    required final String fallbackName,
  }) {
    final topic = row['topic'];
    final rowThreadId = row['threadId'];
    return WorkThreadLink(
      workThreadId: rowThreadId is String && rowThreadId.isNotEmpty
          ? rowThreadId
          : workThreadId,
      parentThreadId: row['parentThreadId'] is String
          ? row['parentThreadId']! as String
          : parentThreadId,
      projectRoot: row['projectId'] is String
          ? row['projectId']! as String
          : projectRoot,
      name: topic is String && topic.isNotEmpty ? topic : fallbackName,
      createdBy: row['createdBy'] is String ? row['createdBy']! as String : '',
      createdAt: row['createdAt'] is String
          ? row['createdAt']! as String
          : DateTime.now().toUtc().toIso8601String(),
    );
  }

  /// The row reuse key (reads off): the FIRST work row whose parent
  /// and seal match the key — the one-link-per-key law, read from
  /// rows. Null when the scope has no work thread yet.
  Future<WorkThreadLink?> _workLinkFromRows(
    final String parentThreadId,
    final String projectRoot,
  ) async {
    final world = _world;
    if (world == null) return null;
    final rows = await world.projection.threadRows();
    for (final row in rows.values) {
      if (row['parentThreadId'] != parentThreadId) continue;
      if (row['projectId'] != projectRoot) continue;
      final threadId = '${row['threadId'] ?? ''}';
      if (threadId.isEmpty) continue;
      return _workLinkFromRow(
        row,
        workThreadId: threadId,
        parentThreadId: parentThreadId,
        projectRoot: projectRoot,
        fallbackName: _defaultWorkThreadName(projectRoot),
      );
    }
    return null;
  }

  /// The work thread's default name: the project root's last path
  /// segment (a mechanical derivation — this layer carries no l10n
  /// strings; the UI owns presentation).
  static String _defaultWorkThreadName(final String projectRoot) {
    final segments = projectRoot
        .replaceAll(r'\', '/')
        .split('/')
        .where((final segment) => segment.isNotEmpty)
        .toList();
    return segments.isEmpty ? projectRoot : segments.last;
  }

  // ---- project access (ADR 0121/0129: grantable, requestable,
  // listable in-process) ----
  //
  // THIN by the module-reuse law: the grant set, the request rows and
  // the refusal vocabulary are the harness's; these verbs call the host
  // package's canonical functions (`agentProjectGrants`,
  // `projectAccessRequest`, `grantProjectAccess` — the same one
  // `ecsai --grant` runs) and never reimplement them.

  /// The realm world home for the host's grant function: the parent of
  /// the store's `coordination` directory (`grantProjectAccess` reopens
  /// the SAME journal through it — the app-support scope is NOT the
  /// world home in production).
  String? get _worldHome => _world?.store.directory.parent.path;

  /// One actor's durable project grant set (the host's projection read:
  /// `realm_actors.projects` ∪ the actor's seat participant rows),
  /// sorted. Empty when the world is not open (web / not ready) —
  /// callers check [isReady] for the honest absence.
  Future<List<String>> listGrants(final String actorId) async {
    final world = _world;
    if (world == null) return const <String>[];
    final grants = await agentProjectGrants(world.store, actorId);
    return grants.toList()..sort();
  }

  /// Every PENDING project-access request of the realm (all actors) —
  /// the host-written `project_access_requests` rows verbatim, state ==
  /// 'pending'. Empty when the world is not open.
  Future<List<Map<String, Object?>>> pendingAccessRequests() async {
    final world = _world;
    if (world == null) return const <Map<String, Object?>>[];
    final rows = await world.store.scan('project_access_requests');
    return [
      for (final row in rows.values)
        if (row['state'] == 'pending') row,
    ];
  }

  /// Records one durable access request (the host's
  /// `projectAccessRequest`, action 'request'): idempotent per
  /// (actor, project); the operator approves through [grantAccess].
  /// Returns the host's result verbatim.
  Future<Map<String, Object?>> requestAccess(
    final String actorId,
    final String projectRoot,
  ) async {
    final world = _world;
    if (world == null) {
      return const <String, Object?>{'ok': false, 'error': 'realm_not_ready'};
    }
    return projectAccessRequest(
      store: world.store,
      seat: world.authorityFor(actorId),
      args: <String, Object?>{'action': 'request', 'projectId': projectRoot},
    );
  }

  /// The in-process twin of `ecsai --grant`: the host's
  /// `grantProjectAccess` over the realm's world home, then a VERIFY
  /// re-read of the durable grant set — the honest outcome rides the
  /// journal, never message parsing.
  Future<ProjectGrantResult> grantAccess(
    final String actorId,
    final String projectRoot,
  ) async {
    final world = _world;
    final home = _worldHome;
    if (world == null || home == null) {
      return const ProjectGrantResult(
        granted: false,
        message: 'realm_not_ready',
      );
    }
    final message = await grantProjectAccess(
      worldHome: home,
      actor: actorId,
      projectRoot: projectRoot,
    );
    final grants = await agentProjectGrants(world.store, actorId);
    return ProjectGrantResult(
      granted: grants.contains(projectRoot),
      message: message,
    );
  }

  // ---- ADR 0147 — scope grants + channel permission verbs ----
  //
  // The human IS the operator here: the LA wrappers grant with
  // `grantedBy: 'operator'` (no monotonic check — the sovereign lane)
  // and keep the VERIFY re-read law (the honest outcome rides the
  // journal, never the verb's optimism).

  /// One actor's effective scope grants (ADR 0147): legacy project
  /// grants ∪ ledger rows ∪ channel-conferred scopes, each with its
  /// caps and provenance. Empty when the world is not open.
  Future<List<ActorScopeGrant>> listScopeGrants(final String actorId) async {
    final world = _world;
    if (world == null) return const <ActorScopeGrant>[];
    return agentScopeGrants(world.store, actorId);
  }

  /// Grants one scope (project or folder) with optional caps, as the
  /// operator. The VERIFY re-read answers [ProjectGrantResult.granted]
  /// from the derived read — a ledger row that failed to land is
  /// reported, never papered over.
  Future<ProjectGrantResult> grantScope({
    required final String actorId,
    required final String kind,
    required final String root,
    final String? subpath,
    final List<String>? caps,
  }) async {
    final world = _world;
    if (world == null) {
      return const ProjectGrantResult(
        granted: false,
        message: 'realm_not_ready',
      );
    }
    String path;
    String? message;
    try {
      final result = await grantActorScope(
        world.store,
        actorId: actorId,
        scopeKind: kind,
        root: root,
        grantedBy: 'operator',
        subpath: subpath,
        caps: caps,
      );
      path = '${result['path'] ?? ''}';
    } on DurableRealmRefusal catch (refused) {
      return ProjectGrantResult(granted: false, message: refused.code);
    } on Object catch (error) {
      return ProjectGrantResult(granted: false, message: '$error');
    }
    final grants = await agentScopeGrants(world.store, actorId);
    final granted = grants.any((grant) => grant.path == path);
    return ProjectGrantResult(
      granted: granted,
      message: message ?? (granted ? 'granted $path' : 'grant did not land'),
    );
  }

  /// Revokes one scope grant by path. The operator lane (the harness
  /// verb permits the operator, the granter, a superset holder, or the
  /// grantee giving the access back).
  Future<ProjectGrantResult> revokeScope({
    required final String actorId,
    required final String path,
  }) async {
    final world = _world;
    if (world == null) {
      return const ProjectGrantResult(
        granted: false,
        message: 'realm_not_ready',
      );
    }
    try {
      await revokeActorScope(
        world.store,
        actorId: actorId,
        path: path,
        revokedBy: 'operator',
      );
    } on DurableRealmRefusal catch (refused) {
      return ProjectGrantResult(granted: false, message: refused.code);
    } on Object catch (error) {
      return ProjectGrantResult(granted: false, message: '$error');
    }
    final grants = await agentScopeGrants(world.store, actorId);
    return ProjectGrantResult(
      granted: !grants.any((grant) => grant.path == path),
      message: 'revoked $path',
    );
  }

  /// Sets (or clears, [root] null) a channel's WORK SCOPE (ADR 0147):
  /// every member derives the scope as a grant for as long as they are
  /// a member — the Discord-side model, access follows membership. The
  /// harness verb manage-gates and (for non-openers) monotonic-checks
  /// the setter. Refreshes [channels] and notifies.
  Future<bool> setChannelWorkScope({
    required final String channelId,
    required final String? kind,
    required final String? root,
    final String? subpath,
    final List<String>? caps,
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    try {
      await world.conversation().setChannelWorkScope(
        actor: human,
        threadId: channel.threadId,
        kind: kind,
        root: root,
        subpath: subpath,
        caps: caps,
      );
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sets a channel's access policy (ADR 0147): who reads, who says,
  /// who manages — and optionally the owners list ([owners] null keeps
  /// the current one; the caller is always included by the harness
  /// verb). The defaults (`realm`/`realm`/`members`) are what a thread
  /// WITHOUT the key answers, so `read: 'members'` is the one change
  /// that closes a channel. Manage-gated by the harness verb.
  Future<bool> setChannelAccess({
    required final String channelId,
    final String? read,
    final String? say,
    final String? manage,
    final List<String>? owners,
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    try {
      await world.conversation().setChannelAccess(
        actor: human,
        threadId: channel.threadId,
        access: {'read': ?read, 'say': ?say, 'manage': ?manage},
        owners: owners,
      );
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Invites members into a channel (ADR 0147 — the first verb that
  /// grows membership other than speaking). Manage-gated; idempotent
  /// per member. Refreshes [channels] and notifies.
  Future<bool> inviteChannelMembers({
    required final String channelId,
    required final List<String> memberIds,
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    try {
      await world.conversation().inviteParticipants(
        actor: human,
        threadId: channel.threadId,
        memberIds: memberIds,
      );
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Removes members from a channel (ADR 0147 — membership can SHRINK;
  /// history is never touched, and a channel-conferred scope leaves
  /// with the member). Manage-gated; refreshing + notifying like its
  /// invite twin.
  Future<bool> removeChannelMembers({
    required final String channelId,
    required final List<String> memberIds,
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    try {
      await world.conversation().removeParticipants(
        actor: human,
        threadId: channel.threadId,
        memberIds: memberIds,
      );
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sets a channel's membership WHOLESALE (the members editor's verb):
  /// the diff against the current participants lands through the
  /// harness invite/remove verbs (ADR 0147), so the manage gate runs on
  /// every mutation and a channel-conferred scope leaves with an
  /// evicted member. Removing the CALLER is refused (an editor cannot
  /// evict itself by accident). History is never touched. Refreshes
  /// [channels] and notifies once.
  Future<bool> setChannelMembers({
    required final String channelId,
    required final List<String> memberIds,
  }) async {
    final world = _world;
    final human = _human;
    if (world == null || human == null) return false;
    final channel = channelByAnyId(channelId);
    if (channel == null) return false;
    // The HUMAN is PERMANENT in channels (owner law, 2026-11-18): a
    // set without the human folds them back in — the self-eviction
    // refusal below stays as the non-human caller's defense.
    final next = <String>{
      human.actor,
      for (final id in memberIds)
        if (id.trim().isNotEmpty) id.trim(),
    }.toList()..sort();
    final current =
        (await world.store.read('threads', channel.threadId))?['participants']
            as List? ??
        const <Object?>[];
    final currentIds = current.cast<String>().toSet();
    final nextIds = next.toSet();
    final toAdd = nextIds.difference(currentIds).toList()..sort();
    final toRemove = currentIds.difference(nextIds).toList()..sort();
    if (toRemove.contains(human.actor)) {
      _error = 'channel_members_self_remove';
      notifyListeners();
      return false;
    }
    final conversation = world.conversation();
    try {
      if (toAdd.isNotEmpty) {
        await conversation.inviteParticipants(
          actor: human,
          threadId: channel.threadId,
          memberIds: toAdd,
        );
      }
      if (toRemove.isNotEmpty) {
        await conversation.removeParticipants(
          actor: human,
          threadId: channel.threadId,
          memberIds: toRemove,
        );
      }
      await refreshThreads();
      notifyListeners();
      return true;
    } on DurableRealmRefusal catch (refused) {
      _error = refused.code;
      notifyListeners();
      return false;
    } on Object catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  // ---- palette revision verbs (Wave J — the provider editor's seam) ----
  //
  // THIN by the module-reuse law: the propose/apply lane IS the host's
  // own durable participation dispatcher (`DurableRealmTools.invoke` →
  // the `palette_propose` / `palette_apply` ops →
  // `proposePaletteRevision` / `applyPaletteRevision` in
  // `palette_admin.dart`, xsoulspace_agentic_host). The host owns the
  // OWNER-ONLY apply gate (`palette_apply_not_owner`, carrying
  // actor/grantId/recovery), the validation gate (the daemon boot's own
  // `parsePaletteConfig` — a structural problem answers with its
  // `PaletteConfigError.code` VERBATIM), the `.bak`-protected write, the
  // `expectedBeforeSha256` race guard (`palette_revision_conflict`) and
  // the `palette_revisions` journal receipt. These verbs add exactly one
  // law of their own: they NEVER throw into the UI (the honest-refusal
  // law) — every lane lands as a structured envelope.

  /// Test seam: pins the palette-health file the revision receipts read
  /// (hermetic tests never touch the device file). Never set from
  /// product.
  @visibleForTesting
  String? debugPaletteHealthPath;

  /// Test seam: overrides the configuration root the palette chain
  /// resolves from (product derives the realm world home — the same
  /// chain the daemon reads). Never set from product.
  @visibleForTesting
  String? debugPaletteConfigRoot;

  /// Validates one candidate `model_palette` object (the host's wire
  /// shape: `providers` + `cast`) against the effective config and
  /// returns the host's proposal receipt VERBATIM — `ok: true` with
  /// `beforeSha256`/`afterSha256`/`diff`/`warnings`, or `ok: false` with
  /// the `PaletteConfigError.code` as the bounce and its message as the
  /// refusal. Open to every seat; read-only (writes nothing).
  Future<Map<String, Object?>> proposePalette(
    final Map<String, Object?> candidate,
  ) => _paletteVerb('palette_propose', candidate);

  /// The OWNER-ONLY palette apply: revalidates, writes the winning
  /// config file with a `.bak` sibling and appends one
  /// `palette_revisions` journal row — the host's receipt verbatim. A
  /// seat without the owner grant answers `ok: false` with the bounce
  /// `palette_apply_not_owner` whose refusal detail carries the
  /// `recovery` text (rendered verbatim by the UI, never a bare error).
  /// [expectedBeforeSha256] is the proposal receipt's race guard.
  Future<Map<String, Object?>> applyPalette(
    final Map<String, Object?> candidate, {
    final String? expectedBeforeSha256,
  }) => _paletteVerb(
    'palette_apply',
    candidate,
    expectedBeforeSha256: expectedBeforeSha256,
  );

  Future<Map<String, Object?>> _paletteVerb(
    final String op,
    final Map<String, Object?> candidate, {
    final String? expectedBeforeSha256,
  }) async {
    final world = _world;
    final seat = _human;
    if (world == null || seat == null) {
      return const <String, Object?>{'ok': false, 'bounce': 'realm_not_ready'};
    }
    try {
      final tools = DurableRealmTools(
        store: world.store,
        queue: DurableTaskQueue(store: world.store),
        // The palette ops read neither (only the `actions` wire and the
        // task admission do) — the dispatcher takes the honest absence.
        palette: null,
        verification: null,
        modelConfigurationRoot: debugPaletteConfigRoot ?? _worldHome,
        paletteHealthPath: debugPaletteHealthPath,
      );
      return await tools.invoke(seat, 'agent_participation', <String, Object?>{
        'op': op,
        'modelPalette': candidate,
        'expectedBeforeSha256': ?expectedBeforeSha256,
      });
    } on Object catch (error) {
      // A transport surprise lands as a named outcome, never as an
      // exception in the UI (the honest-refusal law).
      return <String, Object?>{
        'ok': false,
        'bounce': 'palette_verb_failed',
        'refusal': '$error',
      };
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
    // Notify NOW: the rail's selection fill, badge suppression and the
    // tab title follow the selection immediately — the beats arrive on
    // their own async read (which notifies again when they land).
    notifyListeners();
    unawaited(_refreshBeats());
  }

  /// Says one beat as the human. [addressedTo] narrows the addressees
  /// (the mention grammar: `@name` tokens parsed by the composer); null
  /// keeps the default — every other participant hears it, so a plain
  /// sentence still wakes the whole room. [replyTo] anchors the beat to
  /// an earlier beat number (the 1g quote law — the substrate carries
  /// it, ADR 0136's `replyingTo` vocabulary).
  ///
  /// Wave H — [threadId] is the PANE-INSTANCE target: a conversation
  /// pane pinned to its own surface id says into ITS OWN thread even
  /// while another thread holds the focus. Null keeps today's behavior
  /// byte-identical (the beat rides [activeThreadId]). The addressing
  /// default resolves against the TARGET thread's participants — never
  /// another room's. The active-thread cache refreshes only when the
  /// target IS the active thread; a non-active target's pane re-reads
  /// its own beats through the trailing notify (pure [beatsFor]).
  Future<void> say(
    String text, {
    final int? replyTo,
    final List<String>? addressedTo,
    final String? threadId,
    final List<Map<String, Object?>> attachments = const [],
  }) async {
    final world = _world;
    final human = _human;
    final target = threadId ?? _activeThreadId;
    final trimmed = text.trim();
    if (world == null || human == null || target == null || trimmed.isEmpty) {
      return;
    }
    final others = [
      for (final participant
          in (_threadRowById(target)?['participants'] as List? ??
                  const <Object?>[])
              .cast<String>())
        if (participant != human.actor) participant,
    ];
    _sending = true;
    notifyListeners();
    try {
      await world.conversation().say(
        actor: human,
        threadId: target,
        text: trimmed,
        addressedTo: addressedTo ?? others,
        replyTo: replyTo,
        attachments: attachments,
      );
      // The in-process shortcut: our own append dispatches immediately
      // (the journal watch covers everyone else's).
      _bots?.nudgeDispatcher();
      if (target == _activeThreadId) await _refreshBeats();
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

  /// Post-dispose notifications are a quiet no-op, never a crash: the
  /// journal watch's debounce timer checks [_disposed] when it FIRES,
  /// but an in-flight refresh resumes across its awaits — under load a
  /// teardown can land inside that window, and the trailing notify
  /// would throw ChangeNotifier's debug assert (paid for live: the
  /// acp_bridge load flake, 2026-11-09). The callback is the service's
  /// own tail; nobody will read its state. The assert exists to catch
  /// EXTERNAL misuse of a disposed notifier — our own late callbacks
  /// fade instead.
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
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

/// The verified outcome of one [RealmChatService.grantAccess]:
/// [granted] rides the journal re-read (the actor's durable grant set
/// now names the project), [message] is the host function's own human
/// line (kept verbatim — the module-reuse law, no reinterpretation).
final class ProjectGrantResult {
  const ProjectGrantResult({required this.granted, required this.message});

  final bool granted;
  final String message;

  @override
  String toString() => 'ProjectGrantResult(granted: $granted, $message)';
}
