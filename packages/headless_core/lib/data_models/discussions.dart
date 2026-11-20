import 'document_node.dart';

/// The ADR 0001 discussion-node laws, shared by every surface that opens
/// anchored discussion children (the doc editor, the workbench, a future
/// CLI/TUI): how a discussion child is created and when it is abandoned.
/// The lifecycle ORCHESTRATION (path stack, persistence, collapse flow)
/// stays with the surface; these are the node-level invariants.

/// Node-level discussion laws over [DocumentNode]s.
final class Discussions {
  const Discussions._();

  /// Creates the discussion child anchored to [anchor] on [parent] (ADR
  /// 0001): exactly one anchor block, the anchor's text snapshotted so
  /// the discussion keeps its context after the head is edited, one empty
  /// paragraph to type into.
  static DocumentNode childNode({
    required final DocumentNode parent,
    required final Block anchor,
    required final NodeId Function() newId,
    required final DateTime now,
  }) => DocumentNode(
    id: newId(),
    createdAt: now,
    updatedAt: now,
    parentDocId: parent.id,
    anchorSpan: AnchorSpan(blockId: anchor.id),
    spanSnapshot: anchor.content,
    blocks: [Block(id: newId(), type: BlockType.paragraph)],
  );

  /// Whether climbing up from [child] deletes it (ADR 0001): an OPEN
  /// child left with no content is abandoned — deleted, not archived.
  /// Collapsed children are the document's creation history; they are
  /// archived, never deleted.
  static bool shouldAbandonOnClimb(final DocumentNode child) =>
      child.status == DocumentStatus.open &&
      child.blocks.every((final b) => b.content.trim().isEmpty);
}
