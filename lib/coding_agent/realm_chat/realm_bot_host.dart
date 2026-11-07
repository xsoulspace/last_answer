/// ADR 0023/0024 — the bot host: roster actors with a brain binding
/// become live conversational participants.
///
/// Architecture: ONE dispatcher wake loop listens across the project's
/// threads (under the human's authority — the human's app IS the
/// listening surface) and fans each new beat out to the bot it
/// addresses. A beat addressed to a bot triggers one reply: the bounded
/// thread window becomes the transcript, the roster profile becomes the
/// persona, and the reply is said back under the BOT's own session, so
/// presence accrues from action (ADR 0115 rung 3).
///
/// Why one loop: the realm `wait` poll re-scans the shared journal each
/// tick — N per-bot listeners cost N scans per tick against a journal
/// that also carries the harness's world. One dispatcher + fan-out is
/// the same door-knock at one wake cost.
///
/// Bounds: a bot never answers its own beats, a thread whose tail is one
/// long bot-to-bot chain pauses after [maxConsecutiveBotBeats], and a
/// reply that echoes any of the last few beats — its own OR others' — is
/// dropped (small models echo under repetition pressure).
library;

import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Two bots politely addressing each other stop after this many
/// consecutive bot beats in one thread.
const maxConsecutiveBotBeats = 8;

/// How many thread beats form the reply transcript (small-context law:
/// the window is the context budget).
const _transcriptWindow = 24;

/// How many recent thread beats the echo guard compares against.
const echoGuardWindow = 6;

/// Normalizes a beat text for echo comparison: lowercase, whitespace
/// runs collapsed, trimmed. Punctuation case and layout are noise; the
/// words are the signal.
String normalizeReplyText(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

/// True when an edited profile changes what a live loop EMBODIES: the
/// persona the system prompt builds from (display name, role, custom
/// prompt) or the engine binding ([brainRef] carries the cast AND the
/// sampling query). Editing any of these must rebuild the worker —
/// otherwise an edited brain silently keeps the old engine and an edited
/// persona keeps talking as the old self. Pure, so the rebuild rule
/// tests without a live host.
bool botProfileMateriallyChanged({
  required ActorProfile live,
  required ActorProfile stored,
}) =>
    live.brainRef != stored.brainRef ||
    live.displayName != stored.displayName ||
    live.role != stored.role ||
    live.systemPrompt != stored.systemPrompt;

/// True when [reply] is near-identical to ANY of the [window] most
/// recent [recentBeats] (own OR others' — the observed failure is a bot
/// echoing the human verbatim): an exact normalized match, or containment
/// when the shorter side carries real content (≥ 8 normalized chars —
/// short natural replies like "ok" stay legal). Top-level and pure so it
/// tests without a live brain.
bool isEchoOfRecent({
  required String reply,
  required Iterable<String> recentBeats,
  int window = echoGuardWindow,
}) {
  final normalizedReply = normalizeReplyText(reply);
  if (normalizedReply.isEmpty) return false;
  final beats = recentBeats.map(normalizeReplyText).toList();
  final from = beats.length > window ? beats.length - window : 0;
  for (var i = from; i < beats.length; i++) {
    final beat = beats[i];
    if (beat.isEmpty) continue;
    if (beat == normalizedReply) return true;
    final replyShorter = normalizedReply.length < beat.length;
    final shorter = replyShorter ? normalizedReply : beat;
    final longer = replyShorter ? beat : normalizedReply;
    if (shorter.length >= 8 && longer.contains(shorter)) return true;
  }
  return false;
}

/// Wave 3A — actor activity narration: what one bot is doing RIGHT NOW,
/// one line per actor. The reply loop writes it at each phase change;
/// the People tab and the chat header render it, the state intent
/// exports it. Honest and quiet: no history, no animation — [since]
/// carries the elapsed time.
enum BotNarrationState {
  /// The worker exists but was never addressed.
  idle,

  /// Awake and watching for addressed beats — the quiet normal,
  /// rendered as nothing.
  listening,

  /// A wake landed and the reply cycle is live.
  thinking,

  /// The brain is producing the reply.
  generating,

  /// The cycle failed ([BotNarration.detail] carries the exact status).
  failed,

  /// The echo guard dropped the generated reply.
  droppedEcho,
}

/// One actor's narration line. [detail] is phase-dependent: the thread
/// topic (or the actor being answered) while thinking/generating, the
/// exact status string ('failed: …', 'degraded: …') when failed, 'echo
/// dropped' after a guard drop.
final class BotNarration {
  const BotNarration({required this.state, required this.since, this.detail});

  final BotNarrationState state;
  final String? detail;

  /// When this state began — the UI derives elapsed time from it.
  final DateTime since;

  /// The quiet People-tab line for this narration, null when there is
  /// nothing to say (a listening bot is silence). Elapsed minutes ride
  /// along once the state has held for over a minute.
  String? get statusLine {
    final base = switch (state) {
      BotNarrationState.idle => 'idle',
      BotNarrationState.listening => null,
      BotNarrationState.thinking => 'thinking…',
      BotNarrationState.generating =>
        detail == null || detail!.isEmpty
            ? 'generating reply…'
            : 'generating reply to $detail',
      BotNarrationState.failed => detail ?? 'failed',
      BotNarrationState.droppedEcho => 'echo dropped',
    };
    if (base == null) return null;
    final minutes = DateTime.now().difference(since).inMinutes;
    return minutes > 0 ? '$base · ${minutes}m' : base;
  }
}

/// Runs the shared dispatcher and the live bot workers.
final class RealmBotHost {
  RealmBotHost({
    required this.world,
    required this.humanActorId,
    this.resolveCast,
    this.resolveCredential,
    this.daemonOwnsActor,
    required this.resolveOpenRouterApiKey,
    this.debugBrainOverride,
    this.onChanged,
    this.onWake,
    this.debugStartDispatcher = true,
  });

  /// Test seam: false builds the workers without the shared dispatcher
  /// (rebuild-rule tests never arm its 30s wake timer). Production stays
  /// true — never set from product code.
  @visibleForTesting
  final bool debugStartDispatcher;

  /// Test seam: a brain factory overriding [resolveBrain], so narration
  /// and reply-cycle tests script generations without an engine.
  /// Production stays null — never set from product code.
  @visibleForTesting
  final ActorBrain? Function(ActorProfile actor)? debugBrainOverride;

  final RealmWorld world;

  /// The human actor id: the dispatcher listens under this authority —
  /// the human's app is the listening surface; replies are still said
  /// under each bot's own session.
  final String humanActorId;
  final String? Function() resolveOpenRouterApiKey;

  /// Notified when a bot's status changes (started, failed, stopped).
  final void Function()? onChanged;

  /// Notified once per wake with the fresh beats (the UI subscribes to
  /// this instead of polling the journal itself — one scan, one copier).
  final void Function(List<Map<String, Object?>> beats)? onWake;

  /// G6 — the defer-to-daemon law: when the harness daemon's actor
  /// loops are armed, the actors IT owns (a `cast:` brainRef, or a
  /// durable `brainCast` binding) are answered by the daemon, and this
  /// host stops their in-app loop instead of starting one. ONE answerer
  /// per actor; two is a double-answer. Null = nobody is deferred (the
  /// pre-G6 behavior).
  final bool Function(ActorProfile actor)? daemonOwnsActor;

  /// G6 — the palette rung resolver a `cast:` brainRef rides (the shell
  /// wires it from the world's discovered palette; null = no palette,
  /// a cast ref names nothing).
  final CastBrainDecl? Function(String entryId)? resolveCast;

  /// G6 — credential resolution for palette rungs (env name → value).
  final String? Function(String envName)? resolveCredential;

  final _loops = <String, _BotLoop>{};

  /// actorId → one-line status ('listening', 'failed: …').
  Map<String, String> get statuses => {
    for (final entry in _loops.entries) entry.key: entry.value.status,
  };

  /// Wave 3A — actorId → the actor's current activity narration (live
  /// workers only; a stopped or removed worker leaves with its loop).
  Map<String, BotNarration> get narrations => {
    for (final entry in _loops.entries) entry.key: entry.value.narration,
  };

  /// Debug: the dispatcher's cursor + wake counter (the state intent
  /// surfaces it; never read in product paths).
  Map<String, int> get debugCursor => _wake == null ? const {} : _wake!._cursor;
  int get debugWakes => _wake?._wakes ?? -1;
  int get debugDispatches => _wake?._dispatches ?? -1;

  /// Debug: the live worker object for [actorId], null when none runs —
  /// tests assert a profile edit SWAPS this instance (the rebuild rule);
  /// never read in product paths.
  Object? debugLoopFor(String actorId) => _loops[actorId];

  /// The in-process dispatch shortcut: an app-local say nudges the
  /// dispatcher's drain immediately instead of waiting for the
  /// journal watch's next poll. External appends (daemon actors,
  /// seats) still arrive through the watch on their own cadence.
  void nudgeDispatcher() => _wake?.nudge();

  bool isRunning(String actorId) => _loops.containsKey(actorId);

  /// Aligns the workers with the roster: starts workers for actors with
  /// a resolvable brain, stops workers whose actor left, and REBUILDS a
  /// worker whose profile materially changed ([botProfileMateriallyChanged]
  /// — an owner-approved edit via the actor panel or the Settings pane
  /// must take effect, not silently keep the old brain/persona). The
  /// dispatcher runs while at least one worker exists.
  void syncBots(Iterable<ActorProfile> actors) {
    final wanted = <String>{};
    for (final actor in actors) {
      if (actor.kind == ActorKind.human) continue;
      if (daemonOwnsActor?.call(actor) == true) continue; // deferred
      final brain =
          debugBrainOverride?.call(actor) ??
          resolveBrain(
            actor.brainRef,
            resolveOpenRouterApiKey: resolveOpenRouterApiKey,
            resolveCast: resolveCast,
            resolveCredential: resolveCredential,
          );
      if (brain == null) continue;
      wanted.add(actor.actorId);
      var existing = _loops[actor.actorId];
      if (existing != null &&
          !existing.isStopped &&
          botProfileMateriallyChanged(live: existing.profile, stored: actor)) {
        _loops.remove(actor.actorId)?.stop();
        existing = null;
      }
      if (existing == null || existing.isStopped) {
        final loop = _BotLoop(
          world: world,
          profile: actor,
          brain: brain,
          roster: actors,
          onChanged: onChanged,
        );
        _loops[actor.actorId] = loop;
      }
    }
    for (final id in _loops.keys.toSet()) {
      if (!wanted.contains(id)) _loops.remove(id)?.stop();
    }
    if (debugStartDispatcher && (_wake == null || _wake!.isStopped)) {
      _wake = _WakeLoop(host: this)..start();
    }
    onChanged?.call();
  }

  _WakeLoop? _wake;

  void stopBot(String actorId) {
    _loops.remove(actorId)?.stop();
  }

  void stopAll() {
    for (final loop in _loops.values) {
      loop.stop();
    }
    _loops.clear();
    _wake?.stop();
    _wake = null;
  }
}

/// The one door-knock: ride the journal's append watch and drain the
/// exact tail (the daemon dispatcher's own pattern — the watch event is
/// a HINT, `changesSince` is the truth), fan out by addressing.
///
/// Plane convergence (2026-11-07): the dispatcher no longer rides the
/// `wait` verb — its cross-thread scan is project-filtered, and LA rooms
/// are realm-sealed (visible to every actor, project-free, ADR 0121).
/// The byte-offset drain sees EVERY `thread_beats` append in the realm:
/// the human's says, in-app replies, daemon-owned actors and external
/// seats alike.
final class _WakeLoop {
  _WakeLoop({required this.host}) : _bornAt = DateTime.now().toUtc();
  final RealmBotHost host;

  /// Beats older than the loop's birth never dispatch (a restart never
  /// re-answers history, independent of cursor seeding order).
  final DateTime _bornAt;

  final _cursor = <String, int>{};
  int _wakes = 0;
  int _dispatches = 0;
  bool _stopped = false;
  StreamSubscription<void>? _watchSub;

  /// The journal byte cursor + the drain's re-entrance guard. Nudges
  /// before the seed are no-ops (the first pump drains everything said
  /// since the seed anyway).
  int _offset = 0;
  bool _seeded = false;
  bool _draining = false;
  bool _rerun = false;
  int _failures = 0;

  bool get isStopped => _stopped;

  void start() {
    unawaited(_run());
  }

  void stop() {
    _stopped = true;
    unawaited(_watchSub?.cancel() ?? Future<void>.value());
    _watchSub = null;
  }

  /// The in-process shortcut: a say committed by THIS app drains
  /// immediately instead of waiting for the watch's next poll (external
  /// appends — daemon actors, seats — still ride the watch at its own
  /// cadence, the daemon's pattern).
  void nudge() {
    if (_stopped || !_seeded) return;
    unawaited(_pump());
  }

  Future<void> _run() async {
    final store = host.world.store;
    // Seed at the journal's CURRENT end: history is never re-answered
    // (the born-at guard stays as the second law). The per-thread
    // cursor map seeds alongside for the debug surface.
    _offset = store.journalLength();
    try {
      for (final row in (await host.world.projection.threadRows()).values) {
        final id = row['threadId'];
        final last = row['lastBeat'];
        if (id is String && last is int) _cursor[id] = last;
      }
    } on Object {
      // Debug-surface seeding only; the byte cursor is the truth.
    }
    _seeded = true;

    await _pump();
    if (_stopped) return;
    _watchSub = host.world.watchJournal().listen(
      (_) => unawaited(_pump()),
      onError: (Object e) {
        if (++_failures >= 3) _failLoudly('dispatcher watch');
      },
    );
  }

  /// One drain-to-empty pass with a re-entrance guard: an append that
  /// lands mid-dispatch (a bot's own reply, a second room) sets
  /// [_rerun] and the pass repeats — correctness never relies on the
  /// watch hint, the cursor re-reads the exact tail.
  Future<void> _pump() async {
    if (_draining) {
      _rerun = true;
      return;
    }
    _draining = true;
    final store = host.world.store;
    try {
      do {
        _rerun = false;
        while (!_stopped) {
          final changes = await store.changesSince(_offset);
          if (changes.isEmpty) break;
          final beats = <Map<String, Object?>>[
            for (final record in changes.records)
              for (final mutation in record.mutations)
                if (!mutation.isRemove &&
                    mutation.collection == 'thread_beats' &&
                    mutation.value != null)
                  Map<String, Object?>.from(mutation.value!),
          ];
          _offset = changes.newByteOffset;
          if (beats.isEmpty) continue; // beat-less tail: cursor only
          _wakes++;
          _failures = 0;
          for (final beat in beats) {
            if (_stopped) return;
            final threadId = beat['threadId']! as String;
            final number = beat['beat']! as int;
            _cursor[threadId] = number;
            final addressed = (beat['addressedTo']! as List).cast<String>();
            final author = beat['author']! as String;
            final at = DateTime.tryParse(beat['at'] as String? ?? '');
            if (at != null && at.isBefore(_bornAt)) continue;
            _dispatches++;
            host.onWake?.call([beat]);
            for (final loop in host._loops.values) {
              if (loop.isStopped || loop.profile.actorId == author) continue;
              if (!addressed.contains(loop.profile.actorId)) continue;
              // Serialize generation: one worker at a time keeps the
              // MLX engine honest and replies ordered.
              await loop.handleBeat(beat);
              if (_stopped) return;
            }
          }
        }
      } while (_rerun && !_stopped);
    } on RealmControlStoreException catch (error) {
      if (_stopped) return;
      if (error.code == RealmControlStoreCode.offsetInvalid) {
        // A replaced journal generation: resynchronize at the end.
        _offset = store.journalLength();
      } else if (++_failures >= 3) {
        _failLoudly('dispatcher ${error.code}');
        return;
      }
    } on Object {
      if (_stopped) return;
      if (++_failures >= 3) {
        _failLoudly('dispatcher');
        return;
      }
    } finally {
      _draining = false;
    }
  }

  void _failLoudly(String reason) {
    for (final loop in host._loops.values) {
      loop._setStatus('failed: $reason');
    }
    _stopped = true;
    unawaited(_watchSub?.cancel() ?? Future<void>.value());
    _watchSub = null;
    host.onChanged?.call();
  }
}

/// One bot's reply worker: persona + transcript window + bounds. No
/// listen loop of its own — the dispatcher hands it beats.
final class _BotLoop {
  _BotLoop({
    required this.world,
    required this.profile,
    required this.brain,
    required Iterable<ActorProfile> roster,
    this.onChanged,
  }) : _displayNames = {
         for (final actor in roster) actor.actorId: actor.displayName,
       },
       _botActorIds = {
         for (final actor in roster)
           if (actor.kind != ActorKind.human) actor.actorId,
       };

  final RealmWorld world;
  final ActorProfile profile;
  final ActorBrain brain;
  final Map<String, String> _displayNames;
  final Set<String> _botActorIds;
  final void Function()? onChanged;

  RealmWorldSession? _session;
  bool _stopped = false;
  int _failureStreak = 0;
  String _status = 'idle';
  BotNarration _narration = BotNarration(
    state: BotNarrationState.idle,
    since: DateTime.now().toUtc(),
  );

  bool get isStopped => _stopped;
  String get status => _status;
  BotNarration get narration => _narration;

  /// The string status moves with its coarse narration projection: a
  /// failure (or a degraded generation) lands on `failed` with the exact
  /// status as detail, the living states on their narration verb. The
  /// generation cycle's finer phases (thinking/generating/droppedEcho)
  /// never ride this path — they are set explicitly in [_reply] via
  /// [_setNarration], so the presence derivation keeps reading
  /// 'listening' while a reply is being produced. 'stopped' keeps the
  /// last narration: the loop leaves the map with it.
  void _setStatus(String value) {
    _status = value;
    if (value != 'stopped') {
      final failed =
          value.startsWith('failed:') || value.startsWith('degraded:');
      _narration = BotNarration(
        state: failed ? BotNarrationState.failed : BotNarrationState.listening,
        detail: failed ? value : null,
        since: DateTime.now().toUtc(),
      );
    }
    onChanged?.call();
  }

  /// Wave 3A — a generation-cycle narration phase change. String status
  /// untouched; only the visible narration moves.
  void _setNarration(BotNarrationState state, {String? detail}) {
    _narration = BotNarration(
      state: state,
      detail: detail,
      since: DateTime.now().toUtc(),
    );
    onChanged?.call();
  }

  void stop() {
    _stopped = true;
    _setStatus('stopped');
  }

  /// Replies to one addressed beat (called by the dispatcher, serialized).
  Future<void> handleBeat(Map beat) async {
    if (_stopped) return;
    final session = _session ??= world.sessionFor(profile.actorId);
    // Wave 3A: the dispatcher wake is visible — thinking starts now,
    // naming the actor being answered until the thread topic is known.
    final wokenByAuthor = beat['author']! as String;
    _setNarration(
      BotNarrationState.thinking,
      detail: _displayNames[wokenByAuthor] ?? wokenByAuthor,
    );
    if (_session != null && _status == 'idle') {
      // First use: write the durable registration (idempotent).
      try {
        await session.register(serves: const ['conversation']);
      } on Object {
        _setStatus('failed: registration');
        return;
      }
      _setStatus('listening');
    }
    await _reply(session, beat);
  }

  Future<void> _reply(RealmWorldSession session, Map beat) async {
    final threadId = beat['threadId']! as String;
    final author = beat['author']! as String;
    final conversation = world.conversation();
    final current = beat['beat']! as int;
    final windowAfter = current > _transcriptWindow
        ? current - _transcriptWindow
        : 0;
    final Map<String, Object?> read;
    try {
      read = await conversation.read(
        actor: session.authority,
        threadId: threadId,
        afterBeat: windowAfter,
        limit: _transcriptWindow,
      );
    } on Object {
      // The transcript read failed: the wake produced no work — back to
      // the quiet listening narration, never stuck on thinking.
      _setNarration(BotNarrationState.listening);
      return;
    }
    final window = (read['beats']! as List).cast<Map>();
    // Bot-chain guard: a thread whose tail is one long bot-to-bot
    // exchange pauses this bot until a non-bot word arrives.
    var trailingBotBeats = 0;
    for (final entry in window.reversed) {
      if (!_botActorIds.contains(entry['author'])) break;
      trailingBotBeats++;
    }
    if (trailingBotBeats >= maxConsecutiveBotBeats) {
      _setNarration(BotNarrationState.listening);
      return;
    }

    // Reply grounding: the system prompt names who is being answered;
    // the ADDRESSED beat rides as the FINAL user turn, explicitly marked
    // as the message being answered (speaker-prefixed), so the model's
    // next token is drawn against the right antecedent even when the
    // window is busy. The addressed beat is excluded from the raw
    // window first — it re-enters as the marked final turn.
    final addressedText = (beat['text']! as String).trim();
    final currentBeat = beat['beat']! as int;
    final replyingTo = _displayNames[author] ?? author;
    final turns = [
      for (final entry in window)
        if (entry['beat'] != currentBeat)
          BrainTurn(
            fromMe: entry['author'] == profile.actorId,
            content: entry['text']! as String,
          ),
      BrainTurn(fromMe: false, content: '$replyingTo: $addressedText'),
    ];
    final system = _persona(
      displayName: _displayNames[profile.actorId] ?? profile.displayName,
      role: profile.role,
      replyingTo: replyingTo,
    );
    // Wave 3A: the brain is about to run — the narration names WHAT it
    // works on (the thread topic; a topic-less thread keeps the actor).
    final topic = '${read['topic'] ?? ''}';
    _setNarration(
      BotNarrationState.generating,
      detail: topic.isNotEmpty ? topic : replyingTo,
    );
    final String reply;
    try {
      reply = (await brain.generate(system: system, turns: turns)).trim();
      _failureStreak = 0;
    } on BrainUnavailable catch (error) {
      _setStatus('failed: ${error.reason}');
      return;
    } on BrainGenerationFailed catch (error) {
      _failureStreak++;
      _setStatus(
        _failureStreak >= 3
            ? 'failed: ${error.code}'
            : 'degraded: ${error.code}',
      );
      return;
    } on Object {
      _failureStreak++;
      _setStatus('degraded: generate');
      return;
    }
    if (_stopped) return;
    if (reply.isEmpty) {
      _setStatus('listening');
      return;
    }
    // Small-model echo guard: a reply that merely repeats any of the
    // last few beats (own OR others', normalized) is dropped — keeping
    // the thread from filling with copies. Dropped echoes count nothing
    // as failure; the bot stays 'listening' and the narration says what
    // happened to the reply.
    if (isEchoOfRecent(
      reply: reply,
      recentBeats: [for (final entry in window) entry['text']! as String],
    )) {
      _setStatus('listening');
      _setNarration(BotNarrationState.droppedEcho, detail: 'echo dropped');
      return;
    }
    // Channel semantics (ADR 0024): a reply addresses the WHOLE room
    // minus the speaker — the asker first, but every other participant
    // hears it too, so two bots can hold an addressed exchange in one
    // thread. In a two-member DM this is exactly the asker. Bounded by
    // the bot-chain guard above.
    final room = [
      for (final participant
          in (read['participants'] as List? ?? const <Object?>[])
              .cast<String>())
        if (participant != profile.actorId) participant,
    ];
    try {
      await session.say(
        threadId,
        _clamp(reply),
        addressedTo: room.isEmpty ? <String>[author] : room,
      );
      _setStatus('listening');
    } on DurableRealmRefusal catch (refusal) {
      _setStatus('failed: ${refusal.code}');
    } on Object {
      _setStatus('degraded: say');
    }
  }

  /// The system prompt for one reply. An owner-authored persona
  /// ([ActorProfile.systemPrompt], editable in the actor panel and the
  /// Settings pane) IS the prompt verbatim — the one-line reply
  /// discipline below is still appended, because those bounds are the
  /// host's, not the persona's. Without one, today's synthesized shape.
  String _persona({
    required String displayName,
    required String role,
    required String replyingTo,
  }) {
    if (profile.systemPrompt.isNotEmpty) {
      return '${profile.systemPrompt}\n${_replyDiscipline(replyingTo)}';
    }
    final roleLine = role.isEmpty ? '' : '\nRole: $role.';
    return 'You are $displayName, a participant in a shared '
        'conversation.$roleLine'
        '\n${_replyDiscipline(replyingTo)}';
  }

  /// The one-line reply discipline every persona carries: the bounds
  /// that keep a small model conversational (one message, answer the
  /// addressed beat, no echoes, no meta).
  String _replyDiscipline(String replyingTo) =>
      'Reply to $replyingTo with ONE short conversational message. '
      'The last message is the one you are answering. '
      'Never repeat a message that was already said. '
      'No name labels, no signatures, no roleplay directions.';

  String _clamp(String text) {
    final bytes = utf8.encode(text).length;
    if (bytes <= 8192) return text;
    var end = text.length;
    while (end > 0 && utf8.encode(text.substring(0, end)).length > 8192) {
      end -= 16;
    }
    return text.substring(0, end.clamp(0, text.length));
  }
}
