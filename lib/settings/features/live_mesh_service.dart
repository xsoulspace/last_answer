import 'dart:async';

import 'package:meta/meta.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';
import 'package:universal_storage_realtime/universal_storage_realtime.dart';

/// The live multiplayer plane (ADR 0050 adoption): who is here, what each
/// actor is doing right now, and where their attention sits — so a human
/// can watch agents work, agents can consult who is around, and paired
/// devices share one live picture. Wi-Fi/LAN only, over the SAME relay
/// the mesh sync already hosts, on a DEDICATED registration
/// (`<peerId>-rt`): the relay keys clients by declared id, so the live
/// plane coexists with the sync registration without touching its
/// transport.
///
/// Topology (the multiplayer-chat owner/peer shape): the main device
/// HOSTS ([host]); secondaries dial it ([join]) and publish their local
/// actor activity. The owner folds every sender's events into a roster
/// and rebroadcasts it as a droppable `live-state` frame — newest-wins
/// per type makes the immediate rebroadcast self-throttling, so every
/// device converges on the same live picture without a schedule.
///
/// Privacy law (the human is sovereign):
///  - Agent-actor activity ALWAYS flows to the human's devices — agents
///    already operate on shared world state; watching them is the point.
///  - HUMAN-originated activity leaves the device only while
///    [shareHumanActivity] is true (default FALSE — opt-in), and only at
///    activity granularity (verbs + doc focus): never keystrokes, never
///    doc content.
///  - The gate is enforced AT THE SOURCE ([publish] refuses unshared
///    human events), so the owner's rebroadcast cannot leak what a peer
///    chose not to share.
///
/// Frame authentication is the plane's one honest gap: the relay is an
/// untrusted router and live frames are not signed (presence frames are,
/// ADR 0031). The adopt gate closes the door to unpaired peers — only
/// `<pairedPeerId>-rt` registrations may drive — and the LAN-only
/// transport bounds exposure; an AEAD upgrade would follow the vosges
/// `SessionAeadTransport` pattern.
final class LiveMeshService {
  LiveMeshService._({
    required this.selfId,
    required this.isOwner,
    required this._client,
  });

  /// Opens the plane: binds a realtime registration (`<selfId>-rt`) on
  /// the relay at [endpoint]. Call [host] (main device) or [join]
  /// (secondary) afterwards — hosting arms the aggregator, joining dials
  /// the owner. [pairedPeerIds] arms the owner's adoption gate.
  static Future<LiveMeshService> open({
    required final String selfId,
    required final Uri endpoint,
    required final bool isOwner,
    final Set<String> pairedPeerIds = const <String>{},
  }) async {
    final client = AddressedRelayClient(
      selfId: _transportIdOf(selfId),
      endpoint: endpoint,
    );
    await client.openRelay();
    final service = LiveMeshService._(
      selfId: selfId,
      isOwner: isOwner,
      client: client,
    );
    service._pairedPeerIds.addAll(pairedPeerIds);
    return service;
  }

  final String selfId;
  final bool isOwner;
  final AddressedRelayClient _client;
  final Set<String> _pairedPeerIds = {};

  RealtimeHost? _host;
  RealtimeLink? _link;

  /// The aggregated live picture (owner: folded from senders + this
  /// device's own publishes; peer: the owner's latest rebroadcast).
  final Map<String, LiveActor> _roster = {};
  final Map<String, LiveCursor> _cursors = {};

  /// Actor ids published by THIS device — what [setSharing] may retract.
  final Set<String> _localActorIds = {};

  /// Whether THIS device's human-originated activity is published.
  /// Default false — sharing yourself is opt-in (the privacy law).
  bool shareHumanActivity = false;

  /// Fires whenever the live picture changed. UI and agent surfaces
  /// listen here.
  final _onChanged = StreamController<void>.broadcast();
  Stream<void> get onChanged => _onChanged.stream;

  /// The known actors, freshest activity first.
  List<LiveActor> get actors {
    final list = _roster.values.toList()
      ..sort((final a, final b) => b.since.compareTo(a.since));
    return List.unmodifiable(list);
  }

  /// The known attention points, keyed by actor id.
  Map<String, LiveCursor> get cursors => Map.unmodifiable(_cursors);

  /// The live entry for [actorId], null when absent.
  LiveActor? actor(final String actorId) => _roster[actorId];

  LiveCursor? cursorOf(final String actorId) => _cursors[actorId];

  /// Owner mode: arms the aggregator over the realtime plane.
  void host({final void Function(String message)? log}) {
    if (!isOwner) {
      throw StateError('only the main device hosts the live plane');
    }
    final host = RealtimeHost(
      claimedPlane: _client,
      selfId: _transportIdOf(selfId),
      // The auth gate: only paired peers' realtime registrations may
      // drive. Frame signing is a documented gap; this is the door.
      adoptSession: (final session) {
        final peer = _selfIdOf(session.remotePeerId);
        final known = _pairedPeerIds.contains(peer);
        if (!known) log?.call('live plane rejected $peer (not paired)');
        return known;
      },
      onEvent: (final event, {required final bool authoritative}) =>
          _onEvent(event),
      log: log,
    );
    host.start();
    _host = host;
  }

  /// Secondary mode: dials the owner and opens this device's publish
  /// link. The owner's roster gains this device's actors on publish.
  Future<void> join({required final String ownerId}) async {
    if (isOwner) {
      throw StateError('the main device does not dial itself');
    }
    final session = await _client.connect(
      MeshPeerRecord(peerId: _transportIdOf(ownerId), displayName: ownerId),
    );
    final link = RealtimeLink(session: session);
    _link = link;
    link.inbound.listen(_onEvent);
  }

  /// Publishes this device's local actor activity. HUMAN actors are
  /// refused while [shareHumanActivity] is false (the gate is at the
  /// source — the owner can only rebroadcast what left a device).
  Future<void> publish(final LiveActor actor) async {
    if (!actor.isAgent && !shareHumanActivity) return;
    _localActorIds.add(actor.actorId);
    _roster[actor.actorId] = actor;
    _onChanged.add(null);
    if (isOwner) {
      await _rebroadcast();
    } else {
      await _link?.sendDroppable(_activityType, actor.toJson());
    }
  }

  /// Publishes this device's local actor attention (doc + range). Same
  /// human gate as [publish]; a cursor carries offsets, never content.
  Future<void> publishCursor(final LiveCursor cursor) async {
    if (!cursor.isAgent && !shareHumanActivity) return;
    _localActorIds.add(cursor.actorId);
    _cursors[cursor.actorId] = cursor;
    _onChanged.add(null);
    if (isOwner) {
      await _rebroadcast();
    } else {
      await _link?.sendDroppable(_cursorType, cursor.toJson());
    }
  }

  /// Stops sharing human activity immediately: this device's own HUMAN
  /// entries leave the live picture everywhere (a retraction frame on
  /// secondaries, a scrub + rebroadcast on the owner). Agent entries stay.
  Future<void> setSharing(final bool enabled) async {
    final wasSharing = shareHumanActivity;
    shareHumanActivity = enabled;
    if (enabled || !wasSharing) return;
    final retractIds = <String>[
      for (final entry in _roster.entries)
        if (_localActorIds.contains(entry.key) && !entry.value.isAgent)
          entry.key,
      for (final cursor in _cursors.values)
        if (_localActorIds.contains(cursor.actorId) && !cursor.isAgent)
          cursor.actorId,
    ];
    await _retract(retractIds);
  }

  /// Removes [actorIds] from the live picture and lets every other device
  /// know (owner: scrub + rebroadcast; peer: reliable retraction frame —
  /// the owner rebroadcasts the scrubbed picture from there).
  Future<void> _retract(final List<String> actorIds) async {
    if (actorIds.isEmpty) return;
    for (final actorId in actorIds) {
      _roster.remove(actorId);
      _cursors.remove(actorId);
    }
    _onChanged.add(null);
    if (isOwner) {
      await _rebroadcast();
    } else {
      await _link?.sendReliable(_retractType, {'actorIds': actorIds});
    }
  }

  void _onEvent(final RealtimeEvent event) {
    final payload = event.payload;
    switch (event.type) {
      case _activityType:
        final actor = LiveActor.fromJson(payload);
        _roster[actor.actorId] = actor;
      case _cursorType:
        final cursor = LiveCursor.fromJson(payload);
        _cursors[cursor.actorId] = cursor;
      case _stateType:
        // The owner's rebroadcast REPLACES the peer's picture.
        _roster
          ..clear()
          ..addAll({
            for (final actor in _decodeList(payload['actors']))
              actor.actorId: actor,
          });
        _cursors
          ..clear()
          ..addAll({
            for (final cursor in _decodeCursors(payload['cursors']))
              cursor.actorId: cursor,
          });
      case _retractType:
        for (final actorId
            in (payload['actorIds'] as List<dynamic>? ?? const [])
                .whereType<String>()) {
          _roster.remove(actorId);
          _cursors.remove(actorId);
        }
      default:
        return;
    }
    _onChanged.add(null);
    // Owner aggregation: everything a sender published reaches every
    // other sender through the rebroadcast.
    if (isOwner) unawaited(_rebroadcast());
  }

  /// Owner: pushes the whole picture to every sender. Droppable
  /// newest-wins per type: an event burst coalesces into the latest
  /// state frame — the rebroadcast schedule IS the link's send queue.
  Future<void> _rebroadcast() async {
    final host = _host;
    if (host == null) return;
    final state = <String, Object?>{
      'actors': [for (final actor in actors) actor.toJson()],
      'cursors': [for (final cursor in _cursors.values) cursor.toJson()],
    };
    for (final sender in host.senders) {
      await host.sendTo(sender.peerId, _stateType, state);
    }
  }

  Future<void> dispose() async {
    await _link?.close();
    _link = null;
    await _host?.close();
    _host = null;
    await _client.close();
    await _onChanged.close();
  }
}

List<LiveActor> _decodeList(final Object? raw) => [
  for (final entry in (raw as List<dynamic>? ?? const []))
    if (entry is Map) LiveActor.fromJson(Map<String, Object?>.from(entry)),
];

List<LiveCursor> _decodeCursors(final Object? raw) => [
  for (final entry in (raw as List<dynamic>? ?? const []))
    if (entry is Map) LiveCursor.fromJson(Map<String, Object?>.from(entry)),
];

/// The actor of the live picture: a human or an agent, with a verb for
/// what they are doing right now. Activity granularity ONLY — a verb, a
/// doc focus, a short detail string. Never content, never keystrokes.
@immutable
final class LiveActor {
  const LiveActor({
    required this.actorId,
    required this.displayName,
    required this.isAgent,
    required this.verb,
    this.docId,
    this.detail,
    required this.since,
  });

  factory LiveActor.fromJson(final Map<String, Object?> json) => LiveActor(
    actorId: json['actorId']! as String,
    displayName: (json['name'] as String?) ?? json['actorId']! as String,
    isAgent: json['agent'] as bool? ?? false,
    verb: (json['verb'] as String?) ?? LiveVerbs.idle,
    docId: json['docId'] as String?,
    detail: json['detail'] as String?,
    since: DateTime.fromMillisecondsSinceEpoch(
      json['since'] as int? ?? 0,
      isUtc: true,
    ),
  );

  final String actorId;
  final String displayName;
  final bool isAgent;
  final String verb;

  /// The doc the actor's attention is on, when shared.
  final String? docId;

  /// Short human-readable detail ('refactoring the composer'), bounded
  /// by the publisher's discipline.
  final String? detail;

  /// When this activity state began (the publisher's clock).
  final DateTime since;

  Map<String, Object?> toJson() => {
    'actorId': actorId,
    'name': displayName,
    'agent': isAgent,
    'verb': verb,
    if (docId != null) 'docId': docId,
    if (detail != null) 'detail': detail,
    'since': since.millisecondsSinceEpoch,
  };
}

/// Where an actor's attention sits inside a doc: a range, not content.
@immutable
final class LiveCursor {
  const LiveCursor({
    required this.actorId,
    required this.docId,
    required this.anchor,
    required this.head,
    required this.isAgent,
  });

  factory LiveCursor.fromJson(final Map<String, Object?> json) => LiveCursor(
    actorId: json['actorId']! as String,
    docId: json['docId']! as String,
    anchor: (json['anchor'] as num? ?? 0).toInt(),
    head: (json['head'] as num? ?? 0).toInt(),
    isAgent: json['agent'] as bool? ?? false,
  );

  final String actorId;
  final String docId;

  /// Character offsets into the doc (anchor <= head; a collapsed cursor
  /// is anchor == head).
  final int anchor;
  final int head;

  final bool isAgent;

  Map<String, Object?> toJson() => {
    'actorId': actorId,
    'docId': docId,
    'anchor': anchor,
    'head': head,
    'agent': isAgent,
  };
}

/// The verbs of the live plane. A small closed set keeps the UI
/// renderable and the semantics comparable across actors.
abstract final class LiveVerbs {
  static const editing = 'editing';
  static const thinking = 'thinking';
  static const typing = 'typing';
  static const waiting = 'waiting';
  static const watching = 'watching';
  static const idle = 'idle';
  static const all = <String>[
    editing,
    thinking,
    typing,
    waiting,
    watching,
    idle,
  ];
}

/// The HUMAN half of the live plane: one device's human actor, published
/// through throttled hooks the UI already runs — surface open →
/// [LiveVerbs.watching], composer input → [LiveVerbs.typing] + caret,
/// surface close → [LiveVerbs.idle]. Every call flows through the
/// service's SOURCE gate: while [LiveMeshService.shareHumanActivity] is
/// false, nothing leaves the device (the hooks can fire unconditionally).
final class HumanLivePresence {
  HumanLivePresence({
    required final LiveMeshService service,
    required this.actorId,
    this.displayName = 'Human',
    this.activityHold = const Duration(milliseconds: 1500),
    this.cursorInterval = const Duration(milliseconds: 300),
  }) : _service = service;

  /// This device's human actor id (the mesh peer id — stable, distinct
  /// from agent actors).
  final String actorId;
  final String displayName;
  final LiveMeshService _service;

  /// How long one activity verb stays fresh before the next hook may
  /// re-send (composer input arrives per keystroke; the verb should not
  /// flood). Zero in tests.
  final Duration activityHold;

  /// Minimum spacing between cursor frames.
  final Duration cursorInterval;

  DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCursor = DateTime.fromMillisecondsSinceEpoch(0);
  String? _docId;

  /// The human opened a surface: watching [docId]. Bypasses the throttle
  /// (an open is a real transition, not a stream of noise).
  Future<void> noteOpen(final String docId) =>
      _publish(LiveVerbs.watching, docId, force: true);

  /// Composer input arrived on [docId]: typing while the hold is fresh,
  /// re-sent only after it lapses (the verb stays visually stable).
  Future<void> noteTyping(final String docId) =>
      _publish(LiveVerbs.typing, docId);

  /// The human's caret moved inside [docId] (collapsed range).
  Future<void> noteCursor(
    final String docId, {
    required final int offset,
  }) async {
    final now = DateTime.now();
    if (now.difference(_lastCursor) < cursorInterval) return;
    _lastCursor = now;
    await _service.publishCursor(
      LiveCursor(
        actorId: actorId,
        docId: docId,
        anchor: offset < 0 ? 0 : offset,
        head: offset < 0 ? 0 : offset,
        isAgent: false,
      ),
    );
  }

  /// The surface closed: back to idle on the same doc.
  Future<void> noteClosed() =>
      _publish(LiveVerbs.idle, _docId, force: true);

  Future<void> _publish(
    final String verb,
    final String? docId, {
    final bool force = false,
  }) async {
    final now = DateTime.now();
    if (!force && now.difference(_lastActivity) < activityHold) return;
    _lastActivity = now;
    if (docId != null) _docId = docId;
    await _service.publish(
      LiveActor(
        actorId: actorId,
        displayName: displayName,
        isAgent: false,
        verb: verb,
        docId: _docId,
        since: now.toUtc(),
      ),
    );
  }
}

const String _activityType = 'live-activity';
const String _cursorType = 'live-cursor';
const String _stateType = 'live-state';
const String _retractType = 'live-retract';

String _transportIdOf(final String selfId) => '$selfId-rt';

String _selfIdOf(final String transportId) => transportId.endsWith('-rt')
    ? transportId.substring(0, transportId.length - 3)
    : transportId;
