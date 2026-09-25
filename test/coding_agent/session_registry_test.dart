// ADR 0006 — session ≠ world: the workspace-aware session registry.
//
// Gate (PLAN Phase 5a): several sessions per one workspace are visible and
// legal; one world per workspace stays mandatory (the backend continues
// the same world for the same cwd — proven in harness_host_test.dart);
// the registry is local-first (no sync dependencies).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

import 'scripted_write_mover.dart';

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_registry');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
  });

  HarnessSessionController controller() => HarnessSessionController(
    config: HarnessHostConfig(
      handlerFactory: (_) =>
          ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
    ),
  );

  test('two session projections on one workspace share one world id, '
      'keep independent view ids, and resume instead of duplicating',
      () async {
    final c = controller();
    addTearDown(c.dispose);

    await c.createSession(workspace.path);
    expect(c.workspaces, hasLength(1));
    expect(c.workspaces.single.cwd, workspace.path);
    expect(c.sessions, hasLength(1));

    // ADR 0006: a second session on the same workspace is a NEW projection.
    await c.openNewSession(workspace.path);
    expect(c.workspaces, hasLength(1), reason: 'one workspace, one world');
    expect(c.sessions, hasLength(2));
    final first = c.workspaces.single.sessions[0];
    final second = c.workspaces.single.sessions[1];
    expect(second.id, first.id,
        reason: 'the backend continues ONE world for the same cwd');
    expect(second.viewId, isNot(first.viewId),
        reason: 'projections are distinct even when the world id is shared');
    expect(c.current?.viewId, second.viewId);

    // createSession resumes instead of adding a third projection.
    await c.createSession(workspace.path);
    expect(c.sessions, hasLength(2));
    expect(c.current?.viewId, first.viewId,
        reason: 'resume selects the existing projection with the same id');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('selectSession switches projections inside one workspace', () async {
    final c = controller();
    addTearDown(c.dispose);

    await c.createSession(workspace.path);
    await c.openNewSession(workspace.path);
    final first = c.workspaces.single.sessions[0];
    c.selectSession(first);
    expect(c.current?.viewId, first.viewId);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('switchBackend drops the registry; the NEXT session restores the world',
      () async {
    final c = controller();
    addTearDown(c.dispose);

    await c.createSession(workspace.path);
    expect(c.sessions, hasLength(1));

    await c.switchBackend(
      c.config.copyWith(backend: 'open_router', apiKey: 'test-key'),
    );
    expect(c.workspaces, isEmpty, reason: 'sessions of the old daemon drop');
    expect(c.sessions, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
