// ADR 0026 — the workspace registry tests: CRUD roundtrips, durability
// across registry instances, nesting-as-graph queries (roots, children,
// folder overlap), cycle refusal, and detach-without-recursion delete.
// Hermetic by construction: a plain directory store over a temp dir —
// the same RealmControlStore the world uses, never the real one.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/workspaces/workspace.dart';
import 'package:lastanswer/workspaces/workspace_registry.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  late Directory home;
  late WorkspaceRegistry registry;

  setUp(() async {
    home = await Directory.systemTemp.createTemp('la_workspaces_test');
    registry = WorkspaceRegistry(store: RealmControlStore(home));
  });

  tearDown(() {
    if (home.existsSync()) {
      home.deleteSync(recursive: true);
    }
  });

  group('CRUD roundtrip', () {
    test('create → byId → list keeps every field', () async {
      final workspace = await registry.create(
        name: 'Orbit',
        folderPaths: <String>['/tmp/orbit'],
      );
      expect(workspace.id, startsWith('workspace-'));
      expect(workspace.name, 'Orbit');
      expect(workspace.folderPaths, <String>['/tmp/orbit']);
      expect(workspace.parentIds, isEmpty);

      final loaded = await registry.byId(workspace.id);
      expect(loaded, workspace);
      expect((await registry.list()).length, 1);
    });

    test('create refuses an unknown parent', () async {
      await expectLater(
        registry.create(name: 'Orphan', parentIds: <String>{'workspace-none'}),
        throwsStateError,
      );
    });

    test('create refuses a bad folder path', () async {
      await expectLater(
        registry.create(name: 'Bad', folderPaths: <String>['relative']),
        throwsArgumentError,
      );
      expect(await registry.list(), isEmpty);
    });

    test('rename / addFolders / removeFolders roundtrip', () async {
      final workspace = await registry.create(name: 'Orbit');
      await registry.addFolders(workspace.id, <String>[
        '/tmp/a',
        '/tmp/b',
        '/tmp/a',
      ]);
      expect(
        (await registry.byId(workspace.id))!.folderPaths,
        <String>['/tmp/a', '/tmp/b'],
      );
      await registry.rename(workspace.id, 'Orbit renamed');
      await registry.removeFolders(workspace.id, <String>['/tmp/a']);
      final after = await registry.byId(workspace.id);
      expect(after!.name, 'Orbit renamed');
      expect(after.folderPaths, <String>['/tmp/b']);
    });

    test('project membership roundtrip', () async {
      final workspace = await registry.create(name: 'Orbit');
      await registry.addProject(workspace.id, 'p1');
      expect(
        (await registry.byId(workspace.id))!.projectIds,
        <String>{'p1'},
      );
      await registry.removeProject(workspace.id, 'p1');
      expect((await registry.byId(workspace.id))!.projectIds, isEmpty);
    });

    test('mutations refuse an unknown id', () async {
      await expectLater(
        registry.rename('workspace-none', 'x'),
        throwsStateError,
      );
      await expectLater(
        registry.addFolders('workspace-none', <String>['/tmp/x']),
        throwsStateError,
      );
    });

    test('records survive a fresh registry over the same directory', () async {
      final workspace = await registry.create(
        name: 'Orbit',
        folderPaths: <String>['/tmp/orbit'],
      );
      final reopened = WorkspaceRegistry(store: RealmControlStore(home));
      final loaded = await reopened.byId(workspace.id);
      expect(loaded, workspace);
      expect(loaded!.folderPaths, workspace.folderPaths);
    });
  });

  group('nesting as a graph', () {
    late Workspace root;
    late Workspace child;
    late Workspace grandchild;

    setUp(() async {
      root = await registry.create(name: 'Root');
      child = await registry.create(
        name: 'Child',
        parentIds: <String>{root.id},
      );
      grandchild = await registry.create(
        name: 'Grandchild',
        parentIds: <String>{child.id},
      );
    });

    test('parents exist and childrenOf walks one hop', () async {
      expect(
        (await registry.childrenOf(root.id)).map(
          (final workspace) => workspace.id,
        ),
        <String>{child.id},
      );
      expect(
        (await registry.childrenOf(child.id)).map(
          (final workspace) => workspace.id,
        ),
        <String>{grandchild.id},
      );
      expect(await registry.childrenOf(grandchild.id), isEmpty);
    });

    test('roots lists exactly the zero-parent workspaces', () async {
      expect(
        (await registry.roots()).map((final workspace) => workspace.id),
        <String>{root.id},
      );
    });

    test('a child may hang under MANY parents (overlap)', () async {
      final secondParent = await registry.create(name: 'Second parent');
      await registry.addParent(grandchild.id, secondParent.id);
      final loaded = await registry.byId(grandchild.id);
      expect(loaded!.parentIds, <String>{child.id, secondParent.id});
      // The same child answers under both parents.
      expect(
        (await registry.childrenOf(child.id)).map(
          (final workspace) => workspace.id,
        ),
        contains(grandchild.id),
      );
      expect(
        (await registry.childrenOf(secondParent.id)).map(
          (final workspace) => workspace.id,
        ),
        contains(grandchild.id),
      );
    });

    test('addParent is idempotent and refuses self and cycles', () async {
      await registry.addParent(child.id, root.id);
      expect((await registry.byId(child.id))!.parentIds, <String>{root.id});

      expect(
        () => registry.addParent(child.id, child.id),
        throwsStateError,
      );
      // root → child exists; child → root would close the cycle.
      await expectLater(
        registry.addParent(root.id, child.id),
        throwsStateError,
      );
      // A deeper walk also refuses: root → child → grandchild.
      await expectLater(
        registry.addParent(root.id, grandchild.id),
        throwsStateError,
      );
    });

    test('removeParent keeps the workspace (it may become a root)', () async {
      await registry.removeParent(child.id, root.id);
      final loaded = await registry.byId(child.id);
      expect(loaded, child);
      expect(loaded!.parentIds, isEmpty);
      expect(
        (await registry.roots()).map((final workspace) => workspace.id),
        containsAll(<String>[root.id, child.id]),
      );
    });
  });

  group('folder overlap', () {
    test('one folder may sit in several workspaces', () async {
      await registry.create(name: 'A', folderPaths: <String>['/tmp/shared']);
      await registry.create(name: 'B', folderPaths: <String>['/tmp/shared']);
      await registry.create(name: 'C', folderPaths: <String>['/tmp/other']);

      final containing = await registry.workspacesContainingFolder(
        '/tmp/shared',
      );
      expect(containing.map((final workspace) => workspace.name), <String>[
        'A',
        'B',
      ]);
      expect(
        await registry.workspacesContainingFolder('/tmp/nowhere'),
        isEmpty,
      );
    });

    test('the query normalizes the same way the model does', () async {
      await registry.create(name: 'A', folderPaths: <String>['/tmp/shared']);
      expect(
        (await registry.workspacesContainingFolder(
          '/tmp/./shared/../shared',
        )).length,
        1,
      );
    });
  });

  group('delete', () {
    test('detaches child links, never recurses', () async {
      final root = await registry.create(name: 'Root');
      final child = await registry.create(
        name: 'Child',
        parentIds: <String>{root.id},
      );
      final grandchild = await registry.create(
        name: 'Grandchild',
        parentIds: <String>{child.id},
      );

      await registry.delete(root.id);

      expect(await registry.byId(root.id), isNull);
      // The child survives, now a root; the grandchild link is intact.
      expect((await registry.byId(child.id))!.parentIds, isEmpty);
      expect(
        (await registry.byId(grandchild.id))!.parentIds,
        <String>{child.id},
      );
      expect((await registry.roots()).length, 1);
    });

    test('delete detaches only the deleted edge under overlap', () async {
      final first = await registry.create(name: 'First');
      final second = await registry.create(name: 'Second');
      final shared = await registry.create(
        name: 'Shared child',
        parentIds: <String>{first.id, second.id},
      );

      await registry.delete(first.id);
      expect(
        (await registry.byId(shared.id))!.parentIds,
        <String>{second.id},
      );
    });

    test('deleting an unknown id refuses', () async {
      await expectLater(
        registry.delete('workspace-none'),
        throwsStateError,
      );
    });
  });
}
