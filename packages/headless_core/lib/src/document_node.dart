import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_node.freezed.dart';
part 'document_node.g.dart';

/// Persistent identifier for documents, blocks, and anchors.
///
/// IDs must survive sync/export so anchors stay valid across devices
/// (ADR 0001). UUIDs or content-derived ids both work; the type exists so
/// call sites stay typed and migrations stay possible.
extension type const NodeId(String value) implements String {}

/// Block granularity kinds (ADR 0001 v1: block-level anchoring only).
enum BlockType { heading, paragraph, list, message }

/// Author/sender of a chat message block.
enum ChatRole { user, assistant }

/// Delivery/lifecycle state of a chat message block.
enum MessageStatus { streaming, complete, failed }

/// Lifecycle of a document node.
enum DocumentStatus {
  /// Active; can be edited and can open children.
  open,

  /// Archived after its outcome was applied to the head span. Never deleted;
  /// collapsed nodes are the document's creation history (ADR 0001).
  collapsed,
}

/// One typed block inside a [DocumentNode].
@freezed
abstract class Block with _$Block {
  const factory Block({
    required NodeId id,
    required BlockType type,
    @Default('') String content,

    /// Heading level for [BlockType.heading]; list nesting for lists.
    int? level,

    /// Sender for [BlockType.message]; null otherwise.
    ChatRole? role,

    /// Logical agent/conversation turn id supplied by the caller/backend.
    String? messageId,

    /// Active backend session associated with a message or document stream.
    String? sessionId,

    /// Tool call identifier when the assistant message represents one call.
    String? toolCallId,

    /// Human-readable tool name/title when [toolCallId] is present.
    String? title,
    @Default(MessageStatus.complete) MessageStatus status,
  }) = _Block;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}

/// Anchors a child document to a block in its parent (ADR 0001).
///
/// `prefixHash`/`suffixHash` enable finer anchoring with graceful
/// degradation: when the head text is edited, a matching hash pair narrows
/// the anchor; a mismatch falls back to block-granularity.
@freezed
abstract class AnchorSpan with _$AnchorSpan {
  const factory AnchorSpan({
    required NodeId blockId,
    String? prefixHash,
    String? suffixHash,
  }) = _AnchorSpan;

  factory AnchorSpan.fromJson(Map<String, dynamic> json) =>
      _$AnchorSpanFromJson(json);
}

/// One unified node type for all documents (ADR 0001): head docs, child
/// discussions, templates — recursion falls out because a child is a full
/// [DocumentNode].
@freezed
abstract class DocumentNode with _$DocumentNode {
  const factory DocumentNode({
    required NodeId id,

    required DateTime createdAt, required DateTime updatedAt, /// Only 'doc' today; extensible later without model changes.
    @Default('doc') String kind,

    /// Replaces sealed format enums: 'gdd', 'prd', or any template id.
    /// Null = unformatted doc.
    String? formatId,
    @Default(<Block>[]) List<Block> blocks,

    /// Null = root/head document.
    NodeId? parentDocId,

    /// Required when [parentDocId] != null.
    AnchorSpan? anchorSpan,
    @Default(DocumentStatus.open) DocumentStatus status,

    /// Snapshot of anchored text at creation — the "history note" that
    /// future-proofs against edits, sync bugs, and storage migrations.
    String? spanSnapshot,
  }) = _DocumentNode;

  factory DocumentNode.fromJson(Map<String, dynamic> json) =>
      _$DocumentNodeFromJson(json);
}

/// Validation errors for node invariants (ADR 0001 rules).
extension DocumentNodeX on DocumentNode {
  /// True when this node is a child discussion anchored in a parent.
  bool get isChild => parentDocId != null;

  /// ADR 0001 invariant: children must carry an anchor and a snapshot.
  bool get satisfiesChildInvariants =>
      !isChild || (anchorSpan != null && spanSnapshot != null);

  Block? blockById(NodeId id) {
    for (final block in blocks) {
      if (block.id.value == id.value) return block;
    }
    return null;
  }

  /// Blocks are immutable value objects; returns a copy with [blocks]
  /// replaced and `updatedAt` bumped.
  DocumentNode withBlocks(List<Block> blocks, {DateTime? at}) =>
      copyWith(blocks: blocks, updatedAt: at ?? DateTime.now().toUtc());

  /// Collapses an already-applied child (ADR 0001: the author first applies
  /// the outcome to the head span manually or via explicit agent rewrite;
  /// collapse only archives).
  DocumentNode collapse({DateTime? at}) => copyWith(
    status: DocumentStatus.collapsed,
    updatedAt: at ?? DateTime.now().toUtc(),
  );
}
