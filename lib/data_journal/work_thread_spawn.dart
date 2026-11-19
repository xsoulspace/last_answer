/// The spawn result of the work-thread verb (ADR 0129) — LA-owned
/// policy. The link/registry types it names moved to the harness
/// spaces layer (harness ADR 0144) and ride
/// `conversation_spaces.dart`; the typed result stays here because it
/// IS service policy, not ontology.
library;

import 'package:lastanswer/ecs_plugins/conversation/conversation_spaces.dart';

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
