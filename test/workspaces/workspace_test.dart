// ADR 0026 — the workspace model tests: validation (absolute,
// normalized folders; non-empty names), equality by id, and the
// durable record roundtrip. Pure Dart — no store, no bindings.
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/workspaces/workspace.dart';

Workspace _workspace({
  final String name = 'Orbit',
  final List<String> folders = const <String>[],
  final Set<String> parents = const <String>{},
  final Set<String> projects = const <String>{},
}) => Workspace(
  id: 'workspace-test00000001',
  name: name,
  folderPaths: folders,
  parentIds: parents,
  projectIds: projects,
  createdAt: '2026-10-30T00:00:00.000Z',
);

void main() {
  group('folder path validation', () {
    test('accepts an absolute normalized path unchanged', () {
      expect(
        Workspace.normalizeFolderPath('/Users/antonio/xs/orbit'),
        '/Users/antonio/xs/orbit',
      );
    });

    test('refuses a relative path', () {
      expect(
        () => Workspace.normalizeFolderPath('relative/path'),
        throwsArgumentError,
      );
    });

    test('refuses an empty path', () {
      expect(() => Workspace.normalizeFolderPath('  '), throwsArgumentError);
    });

    test('normalizes dot segments so one folder has one spelling', () {
      expect(
        Workspace.normalizeFolderPath('/Users/antonio/xs/./orbit/../orbit'),
        '/Users/antonio/xs/orbit',
      );
    });

    test('the model constructor normalizes what it stores', () {
      final workspace = _workspace(
        folders: ['/Users/antonio/xs/orbit', '/a/b/../c'],
      );
      expect(workspace.folderPaths, <String>[
        '/Users/antonio/xs/orbit',
        '/a/c',
      ]);
    });

    test('the model constructor refuses relative folders', () {
      expect(() => _workspace(folders: <String>['nope']), throwsArgumentError);
    });
  });

  group('name validation', () {
    test('refuses empty and whitespace-only names', () {
      expect(() => _workspace(name: ''), throwsArgumentError);
      expect(() => _workspace(name: '   '), throwsArgumentError);
    });

    test('trims the stored name', () {
      expect(_workspace(name: '  Orbit  ').name, 'Orbit');
    });
  });

  test('a workspace with zero parents is a root', () {
    expect(_workspace().parentIds, isEmpty);
    expect(
      _workspace(parents: <String>{'workspace-other0000001'}).parentIds,
      isNotEmpty,
    );
  });

  test('equality is by id and nothing else — field drift is the same '
      'workspace', () {
    final first = _workspace();
    final second = _workspace(name: 'Orbit renamed');
    expect(first.id, second.id);
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    // A different id is a different workspace, whatever the fields.
    expect(
      first,
      isNot(
        equals(
          Workspace(
            id: 'workspace-ffffffffffff',
            name: 'Other',
            createdAt: first.createdAt,
          ),
        ),
      ),
    );
  });

  test('the durable record roundtrips through the store shape', () {
    final workspace = _workspace(
      folders: <String>['/Users/antonio/xs/orbit'],
      parents: <String>{'workspace-b00000000001'},
      projects: <String>{'p1', 'p2'},
    );
    final restored = Workspace.fromRecord(workspace.toRecord());
    expect(restored, workspace);
    expect(restored.id, workspace.id);
    expect(restored.name, workspace.name);
    expect(restored.folderPaths, workspace.folderPaths);
    expect(restored.parentIds, workspace.parentIds);
    expect(restored.projectIds, workspace.projectIds);
    expect(restored.createdAt, workspace.createdAt);
  });

  test('minted ids carry the workspace- 24-hex vocabulary', () {
    final pattern = RegExp(r'^workspace-[0-9a-f]{24}$');
    expect(pattern.hasMatch(mintWorkspaceId()), isTrue);
    expect(mintWorkspaceId(), isNot(mintWorkspaceId()));
  });
}
