/// ADR 0129 — the work-thread registry: LA-owned links from parent rooms
/// to project-sealed work threads.
///
/// A **work thread** is a durable thread sealed to a GRANTED project
/// (`open(projectId:)`, never `realmSealed:` — the two are mutually
/// exclusive): the thread's project seal IS the daemon actor's tool-loop
/// sandbox, so a work order dispatched from it lands in the repo the
/// order named instead of the daemon's own project. One work thread per
/// (parent room × project root) — that pair is the REUSE KEY: later
/// orders for the same scope forward into the same thread, never a new
/// thread per beat.
///
/// The registry maps workThreadId ↔ parentThreadId ↔ projectRoot in the
/// LA-owned `work_threads` collection of the SAME realm control store
/// the threads live in (ADR 0024 store law — never a side table). The
/// parent room renders its children as work cards from these links; the
/// order text itself lives ONLY in the work thread.
///
/// The registry is a dumb durable store over [RealmControlStore]; policy
/// (reuse, per-key spawn serialization, grant refusals, order
/// forwarding) lives in `RealmChatService` — the same split as
/// [ChannelRegistry] (ADR 0024).
library;

import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// One registered work-thread link: parent room ↔ work thread ↔ project.
final class WorkThreadLink {
  const WorkThreadLink({
    required this.workThreadId,
    required this.parentThreadId,
    required this.projectRoot,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory WorkThreadLink.fromRecord(final Map<String, Object?> record) =>
      WorkThreadLink(
        workThreadId: record['workThreadId']! as String,
        parentThreadId: record['parentThreadId']! as String,
        projectRoot: record['projectRoot']! as String,
        name: record['name']! as String,
        createdBy: record['createdBy']! as String,
        createdAt: record['createdAt']! as String,
      );

  /// The project-sealed journal thread id (`thread-…` minted by
  /// `DurableConversation.open`). It is ALSO the registry record key:
  /// the link is the thread, so no second id vocabulary is minted.
  final String workThreadId;

  /// The parent room the work thread was spawned from (typically a
  /// realm-sealed channel or group thread — conversational, no project).
  final String parentThreadId;

  /// The granted project root the work thread is sealed to — the daemon
  /// actor's filesystem workRoot when it dispatches beats from here
  /// (ADR 0129: the seal is the sandbox).
  final String projectRoot;

  /// Human-readable name for the parent room's work card (defaults to
  /// the project root's last path segment; the UI owns presentation).
  final String name;

  /// The actor that spawned the link (the human authority).
  final String createdBy;

  /// ISO-8601 UTC instant; `list()` orders by it, oldest first.
  final String createdAt;

  Map<String, Object?> toRecord() => <String, Object?>{
    'workThreadId': workThreadId,
    'parentThreadId': parentThreadId,
    'projectRoot': projectRoot,
    'name': name,
    'createdBy': createdBy,
    'createdAt': createdAt,
  };

  @override
  String toString() =>
      'WorkThreadLink($workThreadId, parent: $parentThreadId, $projectRoot)';
}

/// The LA-owned `work_threads` collection inside the realm's one control
/// store — the same store the threads live in, never a side table
/// (ADR 0024 store law).
final class WorkThreadRegistry {
  WorkThreadRegistry({required this._store});

  final RealmControlStore _store;

  static const _collection = 'work_threads';

  /// Registers the link over an already-opened work thread. Callers
  /// (the service) enforce the one-row-per-reuse-key law; the registry
  /// itself is a dumb put.
  Future<WorkThreadLink> create({
    required final String workThreadId,
    required final String parentThreadId,
    required final String projectRoot,
    required final String name,
    required final String createdBy,
  }) async {
    final record = <String, Object?>{
      'workThreadId': workThreadId,
      'parentThreadId': parentThreadId,
      'projectRoot': projectRoot,
      'name': name.trim(),
      'createdBy': createdBy,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _store.transact(
      (final tx) => tx.put(_collection, workThreadId, record),
    );
    return WorkThreadLink.fromRecord(record);
  }

  /// All registered links, oldest first.
  Future<List<WorkThreadLink>> list() async {
    final records = await _store.scan(_collection);
    final links = [
      for (final record in records.values) WorkThreadLink.fromRecord(record),
    ]..sort((final a, final b) => a.createdAt.compareTo(b.createdAt));
    return links;
  }

  /// The link for the REUSE KEY (parentThreadId, projectRoot), null when
  /// that parent room has no work thread for that project yet.
  Future<WorkThreadLink?> byKey({
    required final String parentThreadId,
    required final String projectRoot,
  }) async {
    for (final link in await list()) {
      if (link.parentThreadId == parentThreadId &&
          link.projectRoot == projectRoot) {
        return link;
      }
    }
    return null;
  }

  /// The link recorded over [workThreadId], null when unknown.
  Future<WorkThreadLink?> byWorkThreadId(final String workThreadId) async {
    final record = await _store.read(_collection, workThreadId);
    return record == null ? null : WorkThreadLink.fromRecord(record);
  }
}

/// The typed result of one `RealmChatService.spawnWorkThread` call.
///
/// Honest-refusal law: the harness's `project_not_granted` refusal
/// (ADR 0129 — the human lacks the durable grant for the requested
/// project) never escapes as an exception; it lands here as [refusal]
/// carrying the actor, the [requestedProject] and the CURRENT [grants]
/// set, so the UI can offer a one-tap grant. A spawn whose thread and
/// registry row landed but whose order beat refused carries BOTH
/// [workThread] and [refusal] — the link stands, only the forward is
/// missing, and nothing is silently dropped.
final class WorkThreadSpawn {
  const WorkThreadSpawn({
    this.workThread,
    this.reused = false,
    this.orderBeat,
    this.refusal,
    this.grants = const <String>[],
    this.requestedProject,
    this.message,
  });

  /// The work-thread link, null when the spawn itself refused.
  final WorkThreadLink? workThread;

  /// True when an existing work thread for the reuse key was returned
  /// instead of opening a second one (the one-per-scope law).
  final bool reused;

  /// The beat number the forwarded order landed as in the WORK thread,
  /// null when no order text was given or the forward refused (named by
  /// [refusal] then).
  final int? orderBeat;

  /// The named refusal (`project_not_granted`, `realm_not_ready`,
  /// `parent_thread_missing`, …), null when nothing refused.
  final String? refusal;

  /// The actor's durable grant set at refusal time — the
  /// `project_not_granted` evidence (ADR 0129's honest-refusal shape).
  final List<String> grants;

  /// The project root the spawn asked to seal to (refusal evidence).
  final String? requestedProject;

  /// Human-readable detail accompanying [refusal] (never a guess).
  final String? message;

  /// Whether the work thread exists (fresh or reused).
  bool get isSpawned => workThread != null;
}
