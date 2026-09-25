/// PLAN 5c — remote permission routing over the doc replica (ADR 0005 §5,
/// DESIGN §9): a pending host permission on the OWNER device is announced
/// as a doc op (`perm/<requestId>`); the answer is a second op on the
/// same register. The whole lifecycle is event-sourced — the kernel owns
/// ordering and dedupe, this router only issues ops and reads the fold.
///
/// Topology (ADR 0005 §3): the device that owns the workspace runs the
/// harness, so permission requests ORIGINATE there. Other paired peers
/// hold input rights: they see the announced requests as remote PERM rows
/// and answer as ops — never through a second protocol.
///
/// Policy lives with the caller ([HarnessSessionController]):
/// `remotePermissionRouting` (default OFF) decides whether pending host
/// permissions are announced as ops at all. OFF = local answering
/// unchanged, nothing is written. ON = the host's permission future
/// completes when the ANSWER op folds into the doc — deny-by-default is
/// preserved (no answer op → no completion; the host's own 5-minute
/// deadline remains the backstop), and a remote answer is recorded on the
/// turn like a local one, indistinguishable except by origin.
library;

import 'package:headless_core/headless_core.dart';

/// One device's doc channel for permission round-trips on ONE document.
/// Stateless over the fold: every read goes to the replica's current
/// state, every write is an op through the [DocReplicaStore] (batched
/// persistence; the mesh sync cycle ships it).
final class PermissionDocRouter {
  PermissionDocRouter({
    required this.store,
    required this.docId,
    required this.selfId,
  });

  /// The doc-replica store participating in the mesh sync cycle
  /// ([MeshStorageService.attachDocSync]). The caller owns its lifecycle.
  final DocReplicaStore store;

  /// The document the permission round-trips belong to.
  final NodeId docId;

  /// THIS device's pairing peer id — the origin of announcements issued
  /// here and the discriminator between own and remote requests.
  final String selfId;

  static int _counter = 0;

  /// Deterministic-per-process, collision-free request id: monotonic
  /// counter + wall clock in base36. Opaque; the register key is
  /// `perm/<requestId>`.
  String nextRequestId() =>
      'perm-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
      '${++_counter}';

  /// Announces a pending permission as a doc op. Returns the [requestId]
  /// the answer must reference. [originActorId] is the acting agent's
  /// roster actor id when the caller can attribute one (ADR 0007 §2:
  /// identity, never authority).
  Future<String> announceRequest({
    required final String title,
    final String? originActorId,
    final DateTime? now,
  }) async {
    final requestId = nextRequestId();
    await store.edit(
      docId,
      (final replica) => replica.announcePermRequest(
        requestId: requestId,
        title: title,
        originPeerId: selfId,
        originActorId: originActorId,
        now: now,
      ),
    );
    return requestId;
  }

  /// Issues the answer op for [requestId] on this device's replica. The
  /// caller's fold picks it up immediately ([refresh]-style readers);
  /// peers pick it up with the next sync cycle. Throws [StateError] when
  /// the request is not pending here (absent or already answered) —
  /// first answer wins, second answers are refused loudly.
  Future<void> answerRequest({
    required final String requestId,
    required final bool allow,
    final String? responderActorId,
    final DateTime? now,
  }) async {
    await store.edit(
      docId,
      (final replica) => replica.answerPermRequest(
        requestId: requestId,
        allow: allow,
        responderPeerId: selfId,
        responderActorId: responderActorId,
        now: now,
      ),
    );
  }

  /// All folded permission records, deterministic order.
  List<PermRequestRecord> entries() =>
      store.replicaOf(docId)?.permRequests() ?? const [];

  /// Requests announced by OTHERS still pending — what a peer device
  /// renders in-flow and may answer (ADR 0005 §3 input rights). Own
  /// announcements render through the local pending-permission flow
  /// (identical to a local request — they ARE one; DESIGN §9).
  List<PermRequestRecord> pendingRemote() => [
    for (final record in entries())
      if (record.isPending && record.originPeerId != selfId) record,
  ];

  /// Every record announced by OTHERS (pending and answered) — the
  /// peer-side flow keeps the decision visible as data, never dropped
  /// (DESIGN §4/§9).
  List<PermRequestRecord> remoteEntries() => [
    for (final record in entries())
      if (record.originPeerId != selfId) record,
  ];
}
