// ADR 0026 — the workspace notifier tests: load-once semantics,
// change notifications around every mutation, the honest unsupported
// state, and null-refusals when no store exists. Hermetic: a plain
// directory store over a temp dir, never the device's world.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  late Directory home;

  setUp(() async {
    home = await Directory.systemTemp.createTemp('la_workspaces_notifier');
  });

  tearDown(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  WorkspaceNotifier notifierOverStore() => WorkspaceNotifier(
    storeLoader: () async => RealmControlStore(home),
  );

  test('ensureLoaded loads once and notifies; a second call joins', () async {
    final notifier = notifierOverStore();
    addTearDown(notifier.dispose);
    var notifications = 0;
    notifier.addListener(() => notifications++);

    await notifier.ensureLoaded();
    expect(notifier.loaded, isTrue);
    expect(notifier.unsupported, isFalse);
    expect(notifier.workspaces, isEmpty);
    expect(notifications, 1);

    // A second ensureLoaded joins the first: no second notification.
    await notifier.ensureLoaded();
    expect(notifications, 1);
  });

  test('create notifies and the list projection grows; delete shrinks',
      () async {
    final notifier = notifierOverStore();
    addTearDown(notifier.dispose);
    await notifier.ensureLoaded();
    var notifications = 0;
    notifier.addListener(() => notifications++);

    final workspace = await notifier.create(name: 'Orbit');
    expect(workspace, isNotNull);
    expect(
      notifier.workspaces.map((final item) => item.name),
      <String>['Orbit'],
    );
    final afterCreate = notifications;
    expect(afterCreate, greaterThanOrEqualTo(1));

    await notifier.delete(workspace!.id);
    expect(notifier.workspaces, isEmpty);
    expect(notifications, greaterThan(afterCreate));
  });

  test('addParent, addFolders and rename notify with the new shape',
      () async {
    final notifier = notifierOverStore();
    addTearDown(notifier.dispose);
    await notifier.ensureLoaded();
    var notifications = 0;
    notifier.addListener(() => notifications++);

    final root = (await notifier.create(name: 'Root'))!;
    final child = (await notifier.create(name: 'Child'))!;
    final before = notifications;

    await notifier.addParent(child.id, root.id);
    await notifier.addFolders(child.id, <String>['/tmp/docs']);
    final renamed = await notifier.rename(child.id, 'Docs');

    expect(renamed!.name, 'Docs');
    expect(renamed.parentIds, <String>{root.id});
    expect(renamed.folderPaths, <String>['/tmp/docs']);
    expect(notifications - before, 3);
    expect(
      notifier.workspaces.where((final item) => item.id == child.id).single,
      renamed,
    );
  });

  test('a null store is honest: unsupported, empty, mutations refuse',
      () async {
    final notifier = WorkspaceNotifier(storeLoader: () async => null);
    addTearDown(notifier.dispose);
    await notifier.ensureLoaded();

    expect(notifier.loaded, isTrue);
    expect(notifier.unsupported, isTrue);
    expect(notifier.loadError, isNull);
    expect(notifier.workspaces, isEmpty);
    expect(await notifier.create(name: 'Nowhere'), isNull);
    expect(notifier.workspaces, isEmpty);
  });

  test('a failing store surfaces its reason and stays empty', () async {
    final notifier = WorkspaceNotifier(
      storeLoader: () async => throw StateError('store unreachable'),
    );
    addTearDown(notifier.dispose);
    await notifier.ensureLoaded();

    expect(notifier.loaded, isTrue);
    expect(notifier.unsupported, isTrue);
    expect(notifier.loadError, contains('store unreachable'));
    expect(notifier.workspaces, isEmpty);
  });
}
