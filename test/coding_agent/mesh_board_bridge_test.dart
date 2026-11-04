import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/mesh_board_bridge.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';

/// The bridge, headless (the boards program, stage 2): the claim → run
/// → settle discipline over a REAL replica and a scripted runner — the
/// same assertions the 6.C widget test makes, without a widget.
void main() {
  final base = DateTime.fromMillisecondsSinceEpoch(1751658000000, isUtc: true);

  MeshTaskBoard board() => MeshTaskBoard(
    replicaId: 'owner-peer',
    now: () => base,
  );

  test('a remote request is claimed, run, and completed with the verdict',
      () async {
    final b = board();
    final peer = MeshTaskBoard(
      replicaId: 'device-a',
      now: () => base.add(const Duration(seconds: 1)),
    );
    final taskId = peer.requestTask(
      docId: 'doc-1',
      task: 'Fix main.dart so dart run exits 0.',
      originPeerId: 'device-a',
    );
    // One mesh exchange lands the request on the owner board.
    b.applyRemote(peer.opsSince(b.versionVector));

    final bridge = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(
        workspace: '/tmp/wk',
        outcome: const DocTurnOutcome(
          verdictLine: 'verdict: PASS (spend 3 decisions / 2 rounds)',
          spend: (decisions: 3, rounds: 2, tokens: 1200, wallMs: 4200),
          stopReason: 'endTurn',
        ),
      ),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    final claimed = await bridge.cycle();
    expect(claimed, taskId);

    final record = b.taskOf(taskId)!;
    expect(record.status, 'completed');
    expect(record.verdict?['verdict'], contains('PASS'));
    expect(record.verdict?['stopReason'], 'endTurn');
    expect(record.verdict?['tokens'], 1200);
    expect(record.verdict?['error'], isNull);
  });

  test('the dispatcher never claims its own announcement', () async {
    final b = board();
    b.requestTask(
      docId: 'doc-1',
      task: 'my own request',
      originPeerId: 'owner-peer',
    );

    final bridge = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(workspace: '/tmp/wk'),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    expect(await bridge.cycle(), isNull);
    expect(b.allRecords.single.status, 'requested');
  });

  test('a request with no bound workspace FAILS honestly on the row',
      () async {
    final b = board();
    final peer = MeshTaskBoard(
      replicaId: 'device-a',
      now: () => base.add(const Duration(seconds: 1)),
    );
    final taskId = peer.requestTask(
      docId: 'doc-1',
      task: 'arrives too early',
      originPeerId: 'device-a',
    );
    b.applyRemote(peer.opsSince(b.versionVector));

    final bridge = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(workspace: null),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    await bridge.cycle();
    final record = b.taskOf(taskId)!;
    expect(record.status, 'failed');
    expect(record.verdict?['error'], 'no workspace bound to the doc yet.');
  });

  test('a cancelled turn is FAILED, never completed', () async {
    final b = board();
    final peer = MeshTaskBoard(
      replicaId: 'device-a',
      now: () => base.add(const Duration(seconds: 1)),
    );
    final taskId = peer.requestTask(
      docId: 'doc-1',
      task: 'cancelled run',
      originPeerId: 'device-a',
    );
    b.applyRemote(peer.opsSince(b.versionVector));

    final bridge = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(
        workspace: '/tmp/wk',
        outcome: const DocTurnOutcome(stopReason: 'cancelled'),
      ),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    await bridge.cycle();
    final record = b.taskOf(taskId)!;
    expect(record.status, 'failed');
    expect(
      record.verdict?['error'],
      'the delegated turn was cancelled before completion.',
    );
    expect(record.verdict?['stopReason'], 'cancelled');
  });

  test('a turn that never ran (config error) FAILS with the config error',
      () async {
    final b = board();
    final peer = MeshTaskBoard(
      replicaId: 'device-a',
      now: () => base.add(const Duration(seconds: 1)),
    );
    final taskId = peer.requestTask(
      docId: 'doc-1',
      task: 'configless run',
      originPeerId: 'device-a',
    );
    b.applyRemote(peer.opsSince(b.versionVector));

    final bridge = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(
        workspace: '/tmp/wk',
        outcome: DocTurnOutcome.failed(
          'backend config for the turn could not be synced: no backend',
        ),
      ),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    await bridge.cycle();
    final record = b.taskOf(taskId)!;
    expect(record.status, 'failed');
    expect(record.verdict?['error'], contains('could not be synced'));
  });

  test('autoRun: false is a pure no-op; re-entrancy is refused mid-cycle',
      () async {
    final b = board();
    final peer = MeshTaskBoard(
      replicaId: 'device-a',
      now: () => base.add(const Duration(seconds: 1)),
    );
    peer.requestTask(
      docId: 'doc-1',
      task: 'not claimed while off',
      originPeerId: 'device-a',
    );
    b.applyRemote(peer.opsSince(b.versionVector));

    final gate = Completer<void>();
    final bridge = MeshBoardBridge(
      board: b,
      runner: _GatedRunner(workspace: '/tmp/wk', gate: gate),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
    );

    final first = bridge.cycle();
    // While the first cycle is in flight, a second cycle is refused.
    final second = await bridge.cycle();
    expect(second, isNull);
    expect(bridge.cycleInFlight, isTrue);
    gate.complete();
    expect(await first, isNotNull);
    expect(bridge.cycleInFlight, isFalse);

    // And the off switch makes the whole loop a no-op.
    final off = MeshBoardBridge(
      board: b,
      runner: _ScriptedRunner(workspace: '/tmp/wk'),
      docId: () => 'doc-1',
      selfPeerId: () => 'owner-peer',
      autoRun: false,
    );
    expect(await off.cycle(), isNull);
  });
}

final class _ScriptedRunner implements DocTurnRunner {
  _ScriptedRunner({required this.workspace, this.outcome});

  final String? workspace;
  final DocTurnOutcome? outcome;

  @override
  String? get boundWorkspace => workspace;

  @override
  Future<DocTurnOutcome> runTurn(final String task) async =>
      outcome ?? const DocTurnOutcome(stopReason: 'endTurn');
}

final class _GatedRunner implements DocTurnRunner {
  _GatedRunner({required this.workspace, required this.gate});

  final String? workspace;
  final Completer<void> gate;

  @override
  String? get boundWorkspace => workspace;

  @override
  Future<DocTurnOutcome> runTurn(final String task) async {
    await gate.future;
    return const DocTurnOutcome(stopReason: 'endTurn');
  }
}
