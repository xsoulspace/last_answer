// The incremental actor-bindings fold (ADR 0120/0143 read path, the
// 2000-actor law): the table is cold-folded once, then only journal
// tail mutations apply — a full-table read per journal event does not
// scale. The maps keep the exact views the service exposed before.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/journal/actor_bindings_fold.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  late Directory tempRoot;
  late RealmControlStore store;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('la_bindings_fold_');
    addTearDown(() => tempRoot.delete(recursive: true));
    store = RealmControlStore(
      Directory('${tempRoot.path}/coordination')..createSync(recursive: true),
    );
  });

  Future<void> putRow(final String actorId, final Map<String, Object?> row) =>
      store.transact((tx) => tx.put('realm_actors', actorId, row));

  Map<String, Object?> actorRow(
    final String actorId, {
    final String? brainCast,
    final List<String>? brainSet,
    final String? selfBind,
  }) => <String, Object?>{
    'actorId': actorId,
    'kind': 'realm_actor',
    'brainCast': ?brainCast,
    'brainSet': ?brainSet,
    'selfBind': ?selfBind,
  };

  group('ActorBindingsFold', () {
    test('the cold fold reads the table once and anchors the cursor', () async {
      await putRow(
        'scout',
        actorRow('scout', brainCast: 'alpha', brainSet: ['alpha']),
      );
      await putRow('iris', <String, Object?>{'actorId': 'iris'});
      final fold = ActorBindingsFold(store);
      await fold.refresh();
      expect(fold.brainCasts, {'scout': 'alpha'});
      expect(fold.brainSets, {
        'scout': ['alpha'],
        'iris': <String>[],
      }, reason: 'every row lands (no set = the empty set fact)');
      expect(fold.selfBinds, isEmpty);
    });

    test('the second refresh reads only the tail — puts and removes '
        'apply incrementally', () async {
      await putRow('scout', actorRow('scout', brainCast: 'alpha'));
      final fold = ActorBindingsFold(store);
      await fold.refresh();
      // A later journal append: rebind + a brand-new actor + a removal.
      await putRow(
        'scout',
        actorRow('scout', brainCast: 'beta', selfBind: 'deny'),
      );
      await putRow('iris', actorRow('iris', brainCast: 'alpha'));
      await store.transact((tx) => tx.remove('realm_actors', 'iris'));
      await fold.refresh();
      expect(fold.brainCasts, {'scout': 'beta'});
      expect(fold.selfBinds, {'scout': 'deny'});
    });

    test('clearing a brain set and unbinding update the maps '
        '(empty = declared-and-cleared)', () async {
      await putRow(
        'scout',
        actorRow('scout', brainCast: 'alpha', brainSet: ['alpha', 'beta']),
      );
      final fold = ActorBindingsFold(store);
      await fold.refresh();
      await putRow('scout', actorRow('scout', brainCast: 'alpha', brainSet: []));
      await fold.refresh();
      expect(
        fold.brainSets['scout'],
        isEmpty,
        reason: 'the entry stays — declared-and-cleared is a fact',
      );
      expect(fold.brainCasts['scout'], 'alpha');
      await putRow('scout', actorRow('scout'));
      await fold.refresh();
      expect(
        fold.brainCasts,
        isEmpty,
        reason: 'the binding leaves the map when the row loses it',
      );
    });

    test('a fresh fold over a mutated table reads current truth '
        '(the refold shape)', () async {
      await putRow('scout', actorRow('scout', brainCast: 'alpha'));
      final fold = ActorBindingsFold(store);
      await fold.refresh();
      expect(fold.brainCasts, {'scout': 'alpha'});
      // A later generation of the table (what a replaced journal
      // refolds into): the fold must see the mutation, not the first
      // view.
      await putRow('scout', actorRow('scout', brainCast: 'beta'));
      final refold = ActorBindingsFold(store);
      await refold.refresh();
      expect(refold.brainCasts, {'scout': 'beta'});
    });
  });
}
