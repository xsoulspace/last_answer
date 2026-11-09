import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/work_thread_registry.dart';

void main() {
  // ADR 0129 — the `work_threads` collection: parent-room ↔ work-thread
  // ↔ project links registered in the realm's ONE control store, written
  // when the work thread is spawned (never a side table, ADR 0024 store
  // law). The registry is the dumb half — reuse policy lives in the
  // service; this suite pins the durable half, mirroring the channel
  // registry suite.
  test('work-thread links round-trip through the realm store', () async {
    final temp = await Directory.systemTemp.createTemp('la_work_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final registry = WorkThreadRegistry(store: world.store);

    final first = await registry.create(
      workThreadId: 'thread-aaaaaaaaaaaa',
      parentThreadId: 'thread-parent00001',
      projectRoot: '/repo/one',
      name: 'one',
      createdBy: 'human-test-device',
    );
    expect(first.workThreadId, 'thread-aaaaaaaaaaaa');
    expect(first.parentThreadId, 'thread-parent00001');
    expect(first.projectRoot, '/repo/one');
    expect(first.name, 'one');
    expect(first.createdBy, 'human-test-device');
    expect(first.createdAt, isNotEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await registry.create(
      workThreadId: 'thread-bbbbbbbbbbbb',
      parentThreadId: 'thread-parent00002',
      projectRoot: '/repo/two',
      name: '  two  ',
      createdBy: 'human-test-device',
    );
    expect(second.name, 'two', reason: 'names are trimmed');

    // list() is sorted by createdAt, oldest first.
    final listed = await registry.list();
    expect(
      listed.map((final link) => link.workThreadId).toList(),
      <String>['thread-aaaaaaaaaaaa', 'thread-bbbbbbbbbbbb'],
    );

    // The REUSE KEY is the (parentThreadId, projectRoot) pair — a
    // half-match is no match.
    final byKey = await registry.byKey(
      parentThreadId: 'thread-parent00001',
      projectRoot: '/repo/one',
    );
    expect(byKey?.workThreadId, 'thread-aaaaaaaaaaaa');
    expect(
      await registry.byKey(
        parentThreadId: 'thread-parent00001',
        projectRoot: '/repo/two',
      ),
      isNull,
    );
    expect(
      await registry.byKey(
        parentThreadId: 'thread-parent00002',
        projectRoot: '/repo/one',
      ),
      isNull,
    );
    expect(
      (await registry.byWorkThreadId('thread-bbbbbbbbbbbb'))?.projectRoot,
      '/repo/two',
    );
    expect(await registry.byWorkThreadId('thread-missing'), isNull);

    // Durable: a fresh registry over the same store sees the records —
    // the link existed before anyone spoke in the work thread.
    final reopened = WorkThreadRegistry(store: world.store);
    final reopenedList = await reopened.list();
    expect(reopenedList, hasLength(2));
    expect(
      (await reopened.byWorkThreadId('thread-aaaaaaaaaaaa'))?.name,
      'one',
    );

    // The rows live in the SAME store's `work_threads` collection.
    final raw = await world.store.read(
      'work_threads',
      'thread-aaaaaaaaaaaa',
    );
    expect(raw?['parentThreadId'], 'thread-parent00001');
    expect(raw?['projectRoot'], '/repo/one');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
