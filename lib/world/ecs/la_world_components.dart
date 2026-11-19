/// LaWorld's row components (1a — the projection law, ADR 0138 D1):
/// the realm journal is the AUTHORITY; this World is a projection, fed
/// by cursor deltas, never written back. One component class per
/// journal collection the UI cares about; fields mirror the row shapes
/// (parsed once at apply time, mutated in place on re-put — heap
/// object components, so creature systems and UI selectors read the
/// same live rows).
///
/// Snapshot typedefs are Dart records: structural equality gives the
/// [EcsWorldSelector] `equals` a cheap, correct comparison — list
/// fields are flattened to joined strings because record equality
/// compares lists by identity, not elementwise.
library;

import 'package:ecsly/ecsly.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart'
    show ActorTelemetry;

/// One `threads` row: a room (DM, channel, or plain thread).
final class RoomRow extends Component {
  RoomRow({
    required this.threadId,
    this.topic = '',
    this.closed = false,
    this.participants = const <String>[],
    this.lastBeat = 0,
    this.createdAt = '',
    this.lastBeatAt,
    this.lastBeatAuthor,
    this.lastBeatText,
    this.realmSealed = false,
  });

  final String threadId;
  String topic;
  bool closed;
  List<String> participants;
  int lastBeat;
  String createdAt;
  String? lastBeatAt;
  String? lastBeatAuthor;
  String? lastBeatText;

  /// True when the row carries no project seal (projectId null) — the
  /// room belongs to the realm (every actor may converse).
  bool realmSealed;

  /// The human's read receipt for this room (`thread_reads`), applied
  /// by the feed; unread = the Discord-law count (everything past the
  /// receipt, not only mentions).
  int lastReadBeat = 0;

  int get unread {
    final delta = lastBeat - lastReadBeat;
    return delta < 0 ? 0 : delta;
  }
}

/// One `durable_tasks` row: a native actor's work loop, from admission
/// to settlement. The sentence and the state word are the journal's —
/// never invented here.
final class TaskRow extends Component {
  TaskRow({
    required this.taskId,
    this.state = '',
    this.sentence = '',
    this.modelId,
    this.addressees = const <String>[],
    this.terminal = false,
    this.summary,
    this.at,
  });

  final String taskId;
  String state;
  String sentence;
  String? modelId;
  List<String> addressees;
  bool terminal;
  String? summary;
  String? at;
}

/// The newest `tool_loop_telemetry` row per actor (the projection keeps
/// only the newest — the journal keeps them all).
final class TelemetryRow extends Component {
  TelemetryRow({required this.actorId, required this.telemetry});

  final String actorId;
  ActorTelemetry telemetry;
}

/// One `realm_actors` row: who exists, what they serve, and the brain
/// binding (the daemon's `brainCast` vocabulary or LA's `brainRef`).
final class ActorRow extends Component {
  ActorRow({
    required this.actorId,
    this.displayName = '',
    this.actorKind = '',
    this.brainRef = '',
    this.brainCast = '',
    this.role = '',
    this.serves = const <String>[],
  });

  final String actorId;
  String displayName;
  String actorKind;
  String brainRef;
  String brainCast;
  String role;
  List<String> serves;
}

// ---- selector snapshots (records: structural equality) ----

typedef RoomSnapshot =
    ({
      String threadId,
      String topic,
      bool closed,
      int lastBeat,
      int unread,
      int participants,
      bool realmSealed,
      String activity,
    });

typedef TaskSnapshot =
    ({
      String taskId,
      String state,
      String sentence,
      String modelId,
      String addressees,
      bool terminal,
      String summary,
      String at,
    });

typedef ActorSnapshot =
    ({
      String actorId,
      String displayName,
      String actorKind,
      String brainRef,
      String brainCast,
      String role,
    });

/// Elementwise snapshot-list equality for [EcsWorldSelector.equals]:
/// records compare structurally, the list compares elementwise.
bool snapshotListEquals<T>(final List<T> previous, final List<T> next) {
  if (previous.length != next.length) return false;
  for (var i = 0; i < previous.length; i++) {
    if (previous[i] != next[i]) return false;
  }
  return true;
}
