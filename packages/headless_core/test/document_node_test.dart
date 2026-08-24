import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';

DocumentNode _child({
  required NodeId id,
  required NodeId parentId,
  required NodeId blockId,
}) => DocumentNode(
  id: id,
  blocks: const [Block(id: NodeId('b1'), type: BlockType.paragraph, content: 'discussion')],
  parentDocId: parentId,
  anchorSpan: AnchorSpan(blockId: blockId),
  spanSnapshot: 'original text',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  test('node round-trips through JSON', () {
    final node = DocumentNode(
      id: const NodeId('doc-1'),
      formatId: 'gdd',
      blocks: const [
        Block(id: NodeId('b-1'), type: BlockType.heading, content: 'Pillars', level: 2),
        Block(id: NodeId('b-2'), type: BlockType.paragraph, content: 'Body text'),
      ],
      createdAt: DateTime.utc(2026, 8, 24),
      updatedAt: DateTime.utc(2026, 8, 24),
    );
    final restored = DocumentNode.fromJson(
      jsonDecode(jsonEncode(node.toJson())) as Map<String, dynamic>,
    );
    expect(restored, node);
  });

  test('child invariants: anchor + snapshot required', () {
    final good = _child(id: const NodeId('c1'), parentId: const NodeId('p'), blockId: const NodeId('b'));
    expect(good.isChild, isTrue);
    expect(good.satisfiesChildInvariants, isTrue);

    final bad = DocumentNode(
      id: const NodeId('c2'),
      parentDocId: const NodeId('p'),
      // no anchorSpan / spanSnapshot
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    expect(bad.satisfiesChildInvariants, isFalse);
  });

  test('collapse archives without deleting', () {
    final child = _child(id: const NodeId('c1'), parentId: const NodeId('p'), blockId: const NodeId('b'));
    final collapsed = child.collapse(at: DateTime.utc(2026, 8, 24));
    expect(collapsed.status, DocumentStatus.collapsed);
    expect(collapsed.spanSnapshot, 'original text'); // history preserved
  });

  test('withBlocks bumps updatedAt', () {
    final node = DocumentNode(
      id: const NodeId('d'),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final edited = node.withBlocks(
      const [Block(id: NodeId('b9'), type: BlockType.list, content: 'item')],
      at: DateTime.utc(2026, 8, 24),
    );
    expect(edited.updatedAt, DateTime.utc(2026, 8, 24));
    expect(edited.blocks, hasLength(1));
  });
}
