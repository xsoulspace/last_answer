// PLAN 5c — the `perm/` LWW lane (ADR 0005 §5): permission round-trips as
// durable doc ops. The request op and the answer op are two writes on ONE
// `perm/<requestId>` register; the kernel owns ordering/dedupe, and the
// answer — issued causally after the request — wins on every replica.

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

void main() {
  final now = DateTime.utc(2026, 9, 6, 12);

  DocReplica replicaOf(final String actor) =>
      DocReplica(nodeId: const NodeId('agent-doc'), actorId: actor);

  test('announce issues a pending perm op on the perm/ register', () {
    final replica = replicaOf('device-a');
    final ops = replica.announcePermRequest(
      requestId: 'perm-1',
      title: 'Write main.dart',
      originPeerId: 'device-a',
      originActorId: 'afm-coder',
      now: now,
    );
    expect(ops, hasLength(1));
    final record = replica.permRequestOf('perm-1');
    expect(record, isNotNull);
    expect(record!.title, 'Write main.dart');
    expect(record.originPeerId, 'device-a');
    expect(record.originActorId, 'afm-coder');
    expect(record.isPending, isTrue);
    expect(record.status, PermRequestStatus.pending);
    expect(record.createdAt, isNotEmpty);
  });

  test('answer wins the register and carries the request fields forward',
      () {
    final replica = replicaOf('device-a')
      ..announcePermRequest(
        requestId: 'perm-1',
        title: 'Write main.dart',
        originPeerId: 'device-a',
        now: now,
      )
      ..answerPermRequest(
        requestId: 'perm-1',
        allow: false,
        responderPeerId: 'device-b',
        now: now.add(const Duration(seconds: 5)),
      );
    final record = replica.permRequestOf('perm-1')!;
    expect(record.status, PermRequestStatus.reject);
    expect(record.isPending, isFalse);
    expect(record.title, 'Write main.dart'); // carried forward
    expect(record.originPeerId, 'device-a'); // carried forward
    expect(record.responderPeerId, 'device-b');
    expect(record.answeredAt, isNotEmpty);
  });

  test('two replicas converge on the same lifecycle (shuffled delivery)',
      () {
    final a = replicaOf('device-a');
    final b = replicaOf('device-b');
    a.announcePermRequest(
      requestId: 'perm-1',
      title: 'Write main.dart',
      originPeerId: 'device-a',
      now: now,
    );
    // A ships its delta to B.
    b.applyRemote(a.pendingOpsSince(b.versionVector));
    // B answers causally after folding the request.
    b.answerPermRequest(
      requestId: 'perm-1',
      allow: true,
      responderPeerId: 'device-b',
      now: now.add(const Duration(seconds: 5)),
    );
    // B's answer ships back; also re-deliver A's own request (dedupe).
    final answers = b.pendingOpsSince(a.versionVector)..shuffle();
    a
      ..applyRemote(answers)
      ..applyRemote(a.pendingOps); // idempotent self-redelivery

    for (final replica in [a, b]) {
      final record = replica.permRequestOf('perm-1')!;
      expect(record.status, PermRequestStatus.allow, reason: '$replica');
      expect(record.responderPeerId, 'device-b');
    }
    expect(
      a.permRequests().map((final r) => r.requestId),
      b.permRequests().map((final r) => r.requestId),
      reason: 'deterministic order on every replica',
    );
  });

  test('answering an absent or already-answered request is refused loudly',
      () {
    final replica = replicaOf('device-a');
    expect(
      () => replica.answerPermRequest(
        requestId: 'ghost',
        allow: true,
        responderPeerId: 'device-a',
        now: now,
      ),
      throwsStateError,
      reason: 'deny-by-default: nothing to answer that was not announced',
    );
    replica
      ..announcePermRequest(
        requestId: 'perm-1',
        title: 'Write main.dart',
        originPeerId: 'device-a',
        now: now,
      )
      ..answerPermRequest(
        requestId: 'perm-1',
        allow: true,
        responderPeerId: 'device-a',
        now: now,
      );
    expect(
      () => replica.answerPermRequest(
        requestId: 'perm-1',
        allow: false,
        responderPeerId: 'device-b',
        now: now,
      ),
      throwsStateError,
      reason: 'first answer wins; second answers never re-decide',
    );
  });

  test('perm entries join the doc replica JSON round-trip', () {
    final replica = replicaOf('device-a')
      ..announcePermRequest(
        requestId: 'perm-1',
        title: 'Write main.dart',
        originPeerId: 'device-a',
        originActorId: 'afm-coder',
        now: now,
      );
    final restored = DocReplica.fromJson(replica.toJson());
    expect(restored.permRequestOf('perm-1')?.title, 'Write main.dart');
    expect(restored.permRequests(), hasLength(1));
  });

  test('malformed perm register values read as absent (DESIGN §6)', () {
    final replica = replicaOf('device-a')
      ..announcePermRequest(
        requestId: 'perm-ok',
        title: 'Write main.dart',
        originPeerId: 'device-a',
        now: now,
      )
      // A foreign op with a broken register value (not JSON) must not
      // take the projection down; the op stays in the doc for inspection.
      // Its HLC is later than the announce's, so the register wins the
      // LWW — and still reads as absent.
      ..applyRemote(const [
        OpRecord(
          docId: 'agent-doc',
          hlc: Hlc(1788696100000, 0, 'device-foreign'),
          payload: {'k': 'perm/perm-bad', 'v': 'not json{'},
        ),
      ]);
    expect(replica.permRequestOf('perm-bad'), isNull);
    expect(replica.permRequests().single.requestId, 'perm-ok');
  });
}
