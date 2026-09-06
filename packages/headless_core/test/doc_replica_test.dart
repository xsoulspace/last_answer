import 'dart:convert';
import 'dart:math';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

const _docId = NodeId('doc-1');
final _now = DateTime.utc(2026, 9, 6, 12);
final _later = DateTime.utc(2026, 9, 6, 12, 0, 1);

DocReplica _replica(final String actorId) =>
    DocReplica(nodeId: _docId, actorId: actorId);

Block _para(final String id, final String content) =>
    Block(id: NodeId(id), type: BlockType.paragraph, content: content);

/// Delivers [ops] to [replica] in one batch — chunked delivery is covered
/// by the per-op test below (the kernel folds in HLC order regardless).
void _deliver(final DocReplica replica, final List<OpRecord> ops) {
  replica.applyRemote(ops, now: _later);
}

void main() {
  group('fractional order keys', () {
    test('between returns strictly-between keys', () {
      expect(fractionalBetween(null, null), 'n');
      expect(fractionalBetween(null, 'n'), 'm');
      expect(fractionalBetween('m', 'z'), 's');
      expect(fractionalBetween('m', 'n'), 'mn');
      expect(fractionalBetween('z', null), 'za');
      expect(fractionalBetween('am', 'aml'), 'amk');
      expect(fractionalBetween('ab', 'abc'), 'abb');
      // Exhaustion returns null → caller must rebalance.
      expect(fractionalBetween(null, 'a'), isNull);
      expect(fractionalBetween('a', 'aa'), isNull);
    });

    test('between results always sort strictly between the bounds', () {
      const bounds = <(String?, String?)>[
        (null, 'm'),
        ('m', 'n'),
        ('n', 'nz'),
        ('a', 'zz'),
        ('mn', 'mo'),
        ('m', null),
        ('zz', null),
      ];
      for (final (lo, hi) in bounds) {
        final mid = fractionalBetween(lo, hi)!;
        if (lo != null) {
          expect(lo.compareTo(mid), lessThan(0), reason: '$lo < $mid');
        }
        if (hi != null) {
          expect(mid.compareTo(hi), lessThan(0), reason: '$mid < $hi');
        }
      }
    });

    test('freshKeys are ordered, distinct, and dense enough', () {
      final keys = freshKeys(50);
      expect(keys.length, 50);
      expect(keys.toSet().length, 50);
      final sorted = [...keys]..sort();
      expect(keys, sorted);
      for (final key in keys) {
        expect(RegExp(r'^[a-z]+$').hasMatch(key), isTrue);
      }
    });
  });

  group('DocReplica', () {
    test('local edits fold into the projection immediately', () {
      final doc = _replica('device-a')
        ..createNode(now: _now)
        ..setNodeField('formatId', value: 'gdd', now: _now)
        ..addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.heading,
            content: 'Pillars',
            level: 2,
          ),
          now: _now,
        )
        ..addBlock(_para('b2', 'Body'), index: 0, now: _now);

      final node = doc.document();
      expect(node.kind, 'doc');
      expect(node.formatId, 'gdd');
      expect(node.blocks.map((b) => b.id.value), ['b2', 'b1']);
      expect(node.blocks[1].type, BlockType.heading);
      expect(node.blocks[1].level, 2);
      expect(node.blocks[1].content, 'Pillars');
      expect(doc.blockText(const NodeId('b2')), 'Body');
      expect(node.createdAt, _now);
    });

    test('two replicas with disjoint edits converge', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', 'Body'), now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      // Disjoint edits: different fields, different blocks.
      final aOps = a.setNodeField('formatId', value: 'gdd', now: _now);
      final bOps = b.addBlock(_para('b2', 'Second'), now: _now);
      _deliver(a, bOps);
      _deliver(b, aOps);

      expect(a.document(), b.document());
      expect(a.document().blocks.map((x) => x.id.value), ['b1', 'b2']);
      expect(a.document().formatId, 'gdd');
    });

    test('conflicting field edits converge to one winner', () {
      final a = _replica('device-a')..createNode(now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      final aOps = a.setNodeField('formatId', value: 'gdd', now: _now);
      final bOps = b.setNodeField('formatId', value: 'prd', now: _later);
      _deliver(a, bOps);
      _deliver(b, aOps);

      expect(a.document(), b.document());
      // B issued at a later HLC → last writer wins deterministically.
      expect(a.document().formatId, 'prd');
    });

    test('every delivery order converges to an identical projection', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..setNodeField('formatId', value: 'gdd', now: _now)
        ..addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.heading,
            content: 'Pillars',
            level: 2,
          ),
          now: _now,
        )
        ..addBlock(_para('b2', 'Body'), now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      // Conflicting and interleaved edits on both sides.
      final bOps = <OpRecord>[
        ...b.setNodeField('formatId', value: 'prd', now: _later),
        ...b.addBlock(
          const Block(
            id: NodeId('b3'),
            type: BlockType.list,
            content: 'Items',
            level: 1,
          ),
          now: _later,
        ),
        ...b.appendText(const NodeId('b2'), ' grows', now: _later),
        ...b.placeChild(
          parentId: _docId,
          childId: const NodeId('c2'),
          index: 0,
          now: _later,
        ),
      ];
      final aOps = <OpRecord>[
        ...a.appendText(const NodeId('b2'), '!', now: _now),
        ...a.deleteTextRange(const NodeId('b2'), 0, 2, now: _now), // 'Bo'
        ...a.placeChild(
          parentId: _docId,
          childId: const NodeId('c1'),
          index: 0,
          now: _now,
        ),
      ];
      _deliver(a, bOps);
      _deliver(b, aOps);

      final fromA = a.pendingOps
          .where((op) => op.actorId == 'device-a')
          .toList();
      final fromB = b.pendingOps
          .where((op) => op.actorId == 'device-b')
          .toList();

      DocReplica project(final List<OpRecord> delivery) =>
          DocReplica(nodeId: _docId, actorId: 'device-c')
            ..applyRemote(delivery, now: _later);

      final reference = project([...fromA, ...fromB]);
      final referenceNode = reference.document();
      final referenceChildren = reference.orderedChildren(_docId.value);

      // Deterministic conflict winner and merged text.
      expect(referenceNode.formatId, 'prd');
      expect(
        reference.blockText(const NodeId('b2')),
        a.blockText(const NodeId('b2')),
      );

      final interleave = <OpRecord>[];
      var ia = 0;
      var ib = 0;
      while (ia < fromA.length || ib < fromB.length) {
        if (ia < fromA.length) interleave.add(fromA[ia++]);
        if (ib < fromB.length) interleave.add(fromB[ib++]);
      }
      final orders = <List<OpRecord>>[
        [...fromA, ...fromB],
        [...fromB, ...fromA],
        [...fromA.reversed, ...fromB.reversed],
        [...fromB.reversed, ...fromA],
        interleave,
        [...fromA, ...fromB]..shuffle(Random(7)),
        [...fromA, ...fromB]..shuffle(Random(99)),
      ];
      for (final order in orders) {
        final r = project(order);
        expect(r.document(), referenceNode, reason: 'order: $order');
        expect(r.orderedChildren(_docId.value), referenceChildren);
      }

      // Per-op delivery (single-op batches) converges too.
      final drip = DocReplica(nodeId: _docId, actorId: 'device-d');
      for (final op in [...fromA, ...fromB].reversed) {
        drip.applyRemote([op], now: _later);
      }
      expect(drip.document(), referenceNode);
      expect(drip.orderedChildren(_docId.value), referenceChildren);

      // Redelivery is a no-op.
      reference.applyRemote([...fromA, ...fromB], now: _later);
      expect(reference.document(), referenceNode);
    });

    test('RGA text merge: concurrent inserts at the same position', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', ''), now: _now)
        ..appendText(const NodeId('b1'), 'Hello', now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);
      expect(b.blockText(const NodeId('b1')), 'Hello');

      // Both type at the end concurrently (streamed agent text case).
      final aOps = a.appendText(const NodeId('b1'), ' world', now: _now);
      final bOps = b.appendText(const NodeId('b1'), ' there', now: _later);
      _deliver(a, bOps);
      _deliver(b, aOps);

      expect(a.blockText(const NodeId('b1')), b.blockText(const NodeId('b1')));
      final merged = a.blockText(const NodeId('b1'));
      expect(merged, contains('Hello'));
      expect(merged.length, 'Hello world there'.length);

      // Concurrent overlapping deletes converge too.
      final aDel = a.deleteTextRange(const NodeId('b1'), 0, 4, now: _later);
      final bDel = b.deleteTextRange(const NodeId('b1'), 2, 6, now: _later);
      _deliver(a, bDel);
      _deliver(b, aDel);
      expect(a.blockText(const NodeId('b1')), b.blockText(const NodeId('b1')));
      expect(a.document(), b.document());
    });

    test('RGA text: concurrent inserts at offset 0 converge (root siblings '
        'order by HLC)', () {
      // Kernel RGA semantics: root-anchored elements sort by (Hlc, index),
      // so an insert at offset 0 issued AFTER older root-anchored content
      // lands after it. Both replicas still converge to one identical
      // text — asserted exactly, including the ordering quirk.
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', 'abcdef'), now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      b.insertTextAt(const NodeId('b1'), 3, 'XY', now: _now);
      _deliver(a, b.pendingOps);
      // b issued 'XY' after receiving a's ops, so its HLC is higher than
      // the 'abcdef' chain's. Kernel sibling order is (Hlc, index)
      // ascending with depth-first traversal, so 'XY' sorts AFTER the
      // 'def' chain that follows its anchor — the merge is deterministic
      // and convergent, but not positionally faithful. Positional
      // mid-text inserts need kernel-side sibling-order support
      // (limitation tracked in the task report).
      expect(a.blockText(const NodeId('b1')), 'abcdefXY');

      a.insertTextAt(const NodeId('b1'), 0, '>', now: _later);
      _deliver(b, a.pendingOps);
      // Same rule at the root anchor: '>' follows the first root-anchored
      // chain.
      expect(b.blockText(const NodeId('b1')), 'abcdefXY>');
      expect(a.blockText(const NodeId('b1')), 'abcdefXY>');
      expect(a.document(), b.document());
    });

    test('fractional rebalance keeps order when keys exhaust', () {
      final a = _replica('device-a')..createNode(now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      // Repeated prepends exhaust the key space below the first child and
      // must trigger rebalancing without losing order.
      final placed = <String>[];
      for (var i = 0; i < 20; i++) {
        final id = 'child-$i';
        a.placeChild(
          parentId: _docId,
          childId: NodeId(id),
          index: 0,
          now: _now,
        );
        placed.insert(0, id);
      }
      expect(a.orderedChildren(_docId.value), placed);

      // All sibling keys are distinct after rebalancing.
      final keys = a
          .orderedChildren(_docId.value)
          .map((c) => a.orderKeyOf(_docId, NodeId(c)))
          .toList();
      expect(keys.toSet().length, keys.length);

      // A second replica receiving the same ops (any order) agrees.
      _deliver(b, a.pendingOps);
      expect(b.orderedChildren(_docId.value), placed);

      // Insertion still works after a rebalance.
      a.placeChild(
        parentId: _docId,
        childId: const NodeId('child-tail'),
        index: 1,
        now: _later,
      );
      _deliver(b, a.pendingOps);
      final expected = [...placed]..insert(1, 'child-tail');
      expect(a.orderedChildren(_docId.value), expected);
      expect(b.orderedChildren(_docId.value), expected);
    });

    test('block removal tombstones across replicas', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', 'Body'), now: _now)
        ..addBlock(_para('b2', 'Keep'), now: _now);
      final b = _replica('device-b');
      _deliver(b, a.pendingOps);

      final ops = a.removeBlock(const NodeId('b1'), now: _now);
      _deliver(b, ops);

      expect(a.document(), b.document());
      expect(a.document().blocks.map((x) => x.id.value), ['b2']);
    });

    test(
      'JSON round-trip through the kernel preserves state and monotonicity',
      () {
        final a = _replica('device-a')
          ..createNode(now: _now)
          ..setNodeField('formatId', value: 'gdd', now: _now)
          ..addBlock(_para('b1', 'Body'), now: _now)
          ..appendText(const NodeId('b1'), ' more', now: _now)
          ..placeChild(
            parentId: _docId,
            childId: const NodeId('c1'),
            index: 0,
            now: _now,
          );

        final json = jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>;
        final restored = DocReplica.fromJson(json);
        expect(restored.document(), a.document());
        expect(
          restored.orderedChildren(_docId.value),
          a.orderedChildren(_docId.value),
        );

        // HLC monotonicity survives the restore: new ops issued with the
        // same wall clock still order after the pre-restore ops.
        final restoredOps = restored.appendText(
          const NodeId('b1'),
          '!',
          now: _now,
        );
        expect(restoredOps, isNotEmpty);

        final b = _replica('device-b');
        _deliver(b, a.pendingOps);
        _deliver(b, restoredOps);
        expect(b.blockText(const NodeId('b1')), 'Body more!');
        expect(b.document(), restored.document());
      },
    );

    test('child documents order independently of blocks', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..setNodeField('parentDocId', value: 'head', now: _now)
        ..setAnchor(const NodeId('head-b2'), now: _now)
        ..placeChild(
          parentId: const NodeId('head'),
          childId: const NodeId('c1'),
          now: _now,
        )
        ..placeChild(
          parentId: const NodeId('head'),
          childId: const NodeId('c2'),
          index: 0,
          now: _now,
        );

      final node = a.document();
      expect(node.parentDocId, const NodeId('head'));
      expect(node.anchorSpan, isNotNull);
      expect(node.anchorSpan!.blockId, const NodeId('head-b2'));
      expect(a.orderedChildren('head'), ['c2', 'c1']);
    });
  });
}
