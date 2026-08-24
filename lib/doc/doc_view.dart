import 'package:flutter/material.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/common_imports.dart';
import 'package:uuid/uuid.dart';

/// Recursive document editor (ADR 0001).
///
/// Renders [doc] blocks as an editable list. Any block can be discussed:
/// "Discuss" creates a child [hc.DocumentNode] anchored to that block
/// (with a snapshot of its content) and dives into it. Navigation uses an
/// internal back-stack ([_path]) with breadcrumbs; collapsed discussions are
/// archived, never deleted.
///
/// Persistence goes through [hc.DocumentRepository] (ADR 0002 hard cut):
/// full node bodies live in headless_core storage; the root's stub stays in
/// ProjectsRepository for listing/routing only.
class DocView extends StatefulWidget {
  const DocView({required this.doc, super.key});
  final ProjectModelDoc doc;

  /// Debug-only snapshot of the open recursive document, published for
  /// MCP agent tooling (`doc_state`, `doc_discuss_block`, `doc_collapse`).
  static DocDebugState? debugDocState;

  @override
  State<DocView> createState() => _DocViewState();
}

const _uuid = Uuid();

hc.NodeId _nextNodeId() => hc.NodeId(_uuid.v4());

/// Converts the root stub from ProjectsRepository into a full node.
hc.DocumentNode _stubToNode(final ProjectModelDoc doc) => hc.DocumentNode(
  id: hc.NodeId(doc.id.value),
  formatId: doc.formatId.isEmpty ? null : doc.formatId,
  blocks: [
    for (final b in doc.blocks)
      hc.Block(
        id: hc.NodeId(b.id.value),
        type: hc.BlockType.values.byName(b.type.name),
        content: b.content,
        level: b.level,
      ),
  ],
  createdAt: doc.createdAt,
  updatedAt: doc.updatedAt,
);

/// Converts a full node back into the root stub for ProjectsRepository.
ProjectModelDoc _nodeToStub(final hc.DocumentNode node) => ProjectModelDoc(
  id: ProjectModelId(node.id.value),
  createdAt: node.createdAt,
  updatedAt: node.updatedAt,
  formatId: node.formatId ?? '',
);

/// Debug-only snapshot of the open recursive document, published for
/// MCP agent tooling (`doc_state`, `doc_discuss_block`, `doc_collapse`).
class DocDebugState {
  const DocDebugState({
    required this.path,
    required this.blocks,
    required this.childrenCounts,
    required this.discussBlock,
    required this.collapseCurrent,
  });

  /// Root first, currently open node last.
  final List<hc.DocumentNode> path;
  final List<hc.Block> blocks;

  /// Per-block count of anchored discussion children (aligned with [blocks]).
  final List<int> childrenCounts;
  final Future<String?> Function(int blockIndex) discussBlock;
  final Future<bool> Function({bool rewriteFromDiscussion}) collapseCurrent;

  hc.DocumentNode get current => path.last;
  int get depth => path.length;
  String get rootDocId => path.first.id.value;
  String get currentDocId => current.id.value;
  String get status => current.status.name;
  int get blockCount => blocks.length;

  Map<String, Object?> toJson() => {
    'depth': depth,
    'rootDocId': rootDocId,
    'currentDocId': currentDocId,
    'status': status,
    'path': [
      for (final node in path)
        {'id': node.id.value, 'status': node.status.name},
    ],
    'blocks': [
      for (var i = 0; i < blocks.length; i++)
        {
          'index': i,
          'type': blocks[i].type.name,
          'content': blocks[i].content,
          'childrenCount': childrenCounts[i],
        },
    ],
  };
}

class _DocViewState extends State<DocView> {
  /// Root first, currently open document last.
  late List<hc.DocumentNode> _path;
  int? _lastFocusedBlockIndex;

  /// Open/collapsed discussion children of the current node, by anchor block.
  Map<hc.NodeId, List<hc.DocumentNode>> _childrenByBlock = {};

  /// Text controllers of visible blocks, for cursor-positioned AI writes.
  final Map<int, TextEditingController> _controllers = {};

  hc.DocumentRepository get _docRepo => context.read<hc.DocumentRepository>();

  @override
  void initState() {
    super.initState();
    _path = [_stubToNode(widget.doc)];
    unawaited(_reloadChildren());
  }

  @override
  void didUpdateWidget(final DocView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doc != widget.doc && _path.length == 1) {
      setState(() => _path[0] = _stubToNode(widget.doc));
    }
  }

  @override
  void dispose() {
    DocView.debugDocState = null;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  hc.DocumentNode get _current => _path.last;

  Future<void> _reloadChildren() async {
    final children = await _docRepo.childrenOf(_current.id);
    final loaded = <hc.DocumentNode>[];
    for (final id in children) {
      final result = await _docRepo.get(id);
      if (result case final hc.DocFound found) loaded.add(found.node);
    }
    if (!mounted) return;
    setState(() {
      _childrenByBlock = <hc.NodeId, List<hc.DocumentNode>>{};
      for (final child in loaded) {
        final blockId = child.anchorSpan?.blockId;
        if (blockId == null) continue;
        _childrenByBlock.putIfAbsent(blockId, () => []).add(child);
      }
    });
  }

  Future<void> _persist(final hc.DocumentNode node) async {
    setState(() => _path[_path.length - 1] = node);
    await _docRepo.save(node);
    if (_path.length == 1) {
      // Keep the listing stub in sync (title/id/routing only).
      context.read<OpenedProjectNotifier>().updateProject(_nodeToStub(node));
    } else {
      final parent = _path[_path.length - 2];
      await _docRepo.save(parent);
    }
  }

  Future<void> _replaceBlock(final int index, final hc.Block block) async {
    final blocks = List<hc.Block>.from(_current.blocks);
    if (index < 0 || index >= blocks.length) return;
    blocks[index] = block;
    await _persist(_current.withBlocks(blocks));
  }

  void _onBlockFocus(final int index, final bool hasFocus) {
    if (hasFocus) _lastFocusedBlockIndex = index;
  }

  void _registerController(final int index, final TextEditingController c) {
    _controllers[index] = c;
  }

  /// Dives into the given child discussion document.
  Future<void> _openChild(final hc.DocumentNode child) async {
    setState(() {
      _path.add(child);
      _lastFocusedBlockIndex = null;
    });
    await _reloadChildren();
  }

  /// Climbs one level up the back-stack. Abandoned open children (created then
  /// left behind via breadcrumb jump) are deleted so the node store stays clean;
  /// collapsed children are archived, never deleted (ADR 0001).
  Future<void> _climbUp() async {
    if (_path.length <= 1) return;
    final child = _path.last;
    if (child.status == hc.DocumentStatus.open) {
      final isEmpty = child.blocks.every((final b) => b.content.trim().isEmpty);
      if (isEmpty) {
        await _docRepo.delete(child.id);
      }
    }
    setState(() {
      _path.removeLast();
      _lastFocusedBlockIndex = null;
    });
    await _reloadChildren();
  }

  /// Creates a discussion child anchored to the block at [index] and dives in.
  /// Returns the new child's id, or null if [index] is out of range.
  Future<String?> _discussBlock(final int index) async {
    final blocks = _current.blocks;
    if (index < 0 || index >= blocks.length) return null;
    final block = blocks[index];
    final now = DateTime.now();
    final child = hc.DocumentNode(
      id: _nextNodeId(),
      createdAt: now,
      updatedAt: now,
      parentDocId: _current.id,
      anchorSpan: hc.AnchorSpan(blockId: block.id),
      spanSnapshot: block.content,
      blocks: [hc.Block(id: _nextNodeId(), type: hc.BlockType.paragraph)],
    );
    await _docRepo.save(child);
    await _openChild(child);
    return child.id.value;
  }

  /// Collapses the current discussion: archives it and climbs back to head.
  /// Returns false when already at the root (nothing to collapse).
  ///
  /// If [rewriteFromDiscussion] is true and an inference port is configured, the
  /// parent's anchored block is rewritten first (agent conclusion → head), per
  /// ADR 0001 — the head is edited by the author or by an explicitly requested
  /// agent rewrite of that exact part, never silently.
  Future<bool> _collapseCurrent({bool rewriteFromDiscussion = false}) async {
    if (_path.length <= 1) return false;
    if (rewriteFromDiscussion) await _rewriteHeadFromDiscussion();
    await _persist(
      _current.copyWith(
        status: hc.DocumentStatus.collapsed,
        updatedAt: DateTime.now(),
      ),
    );
    await _climbUp();
    return true;
  }

  /// Asks the inference port to rewrite the parent's anchored block using the
  /// current discussion child as context, then writes the result into the head.
  Future<void> _rewriteHeadFromDiscussion() async {
    final port = context.read<DocInferencePort?>();
    if (port == null) return;
    final parentIndex = _path.length - 2;
    final parent = _path[parentIndex];
    final anchor = _current.anchorSpan;
    final blockIndex = parent.blocks.indexWhere(
      (final b) => b.id == anchor?.blockId,
    );
    if (blockIndex < 0) return;
    final headBlock = parent.blocks[blockIndex];
    final buffer = StringBuffer();
    await for (final token in port.chat(_buildRewritePrompt(headBlock))) {
      buffer.write(token);
    }
    final rewritten = buffer.toString().trim();
    if (rewritten.isEmpty) return;
    final updatedParent = parent.withBlocks(
      List<hc.Block>.from(parent.blocks)
        ..[blockIndex] = headBlock.copyWith(content: rewritten),
    );
    _path[parentIndex] = updatedParent;
    await _docRepo.save(updatedParent);
  }

  List<ChatMessage> _buildRewritePrompt(final hc.Block headBlock) => [
    const ChatMessage(
      role: 'system',
      content:
          'You are rewriting one block of a design document. The user '
          'discussed the block below and reached a conclusion. Rewrite the '
          'block to reflect that conclusion. Output only the rewritten block '
          'text, nothing else.',
    ),
    ChatMessage(
      role: 'user',
      content:
          'Original block:\n${headBlock.content}\n\n'
          'Discussion:\n${_discussionContext()}',
    ),
  ];

  String _discussionContext() => _current.blocks
      .map((final b) => b.content)
      .where((final c) => c.trim().isNotEmpty)
      .join('\n');

  String _breadcrumbLabel(final hc.DocumentNode node) {
    if (_path.first == node && widget.doc.title.isNotEmpty) {
      return widget.doc.title;
    }
    final snapshot = (node.spanSnapshot ?? '').trim();
    if (snapshot.isNotEmpty) {
      return snapshot.length <= 32 ? snapshot : '${snapshot.substring(0, 32)}…';
    }
    return 'Discussion';
  }

  Future<void> _onAskAi() async {
    final port = context.read<DocInferencePort?>();
    if (port == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No provider configured')));
      return;
    }
    final index = _lastFocusedBlockIndex;
    final controller = index == null ? null : _controllers[index];
    if (controller == null) return;

    final selection = controller.selection;
    final offset = selection.baseOffset < 0
        ? controller.text.length
        : selection.baseOffset;
    final prefix = controller.text.substring(0, offset);
    final suffix = controller.text.substring(offset);

    final buffer = StringBuffer();
    await for (final token in port.chat(_buildPromptMessages())) {
      buffer.write(token);
      final text = '$prefix$buffer$suffix';
      controller
        ..text = text
        ..selection = TextSelection.collapsed(
          offset: prefix.length + buffer.length,
        );
    }
    await _replaceBlock(
      index!,
      _current.blocks[index].copyWith(content: controller.text),
    );
  }

  List<ChatMessage> _buildPromptMessages() {
    final messages = <ChatMessage>[
      for (final block in _current.blocks)
        if (block.content.trim().isNotEmpty)
          ChatMessage(role: 'user', content: block.content),
    ];
    return messages.isEmpty
        ? [const ChatMessage(role: 'user', content: '')]
        : messages;
  }

  @override
  Widget build(final BuildContext context) {
    final isRoot = _path.length == 1;
    assert(() {
      DocView.debugDocState = DocDebugState(
        path: List.of(_path),
        blocks: _current.blocks,
        childrenCounts: [
          for (final block in _current.blocks)
            _childrenByBlock[block.id]?.length ?? 0,
        ],
        discussBlock: _discussBlock,
        collapseCurrent: _collapseCurrent,
      );
      return true;
    }());
    return PopScope(
      /// At depth > 0, system-back climbs the stack instead of leaving.
      canPop: isRoot,
      onPopInvokedWithResult: (final didPop, final _) {
        if (didPop) {
          context.read<OpenedProjectNotifier>().onPopProject();
          return;
        }
        unawaited(_climbUp());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isRoot)
            _BreadcrumbBar(
              path: _path,
              labelBuilder: _breadcrumbLabel,
              onTap: (final index) async {
                while (_path.length > index + 1) {
                  await _climbUp();
                }
                setState(() => _lastFocusedBlockIndex = null);
                await _reloadChildren();
              },
              onCollapse: _collapseCurrent,
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
              itemCount: _current.blocks.length,
              itemBuilder: (final context, final index) {
                final block = _current.blocks[index];
                final children = _childrenByBlock[block.id];
                return _DocBlockTile(
                  key: ValueKey('${_current.id.value}:${block.id.value}'),
                  block: block,
                  blockIndex: index,
                  openChildrenCount:
                      children
                          ?.where((c) => c.status == hc.DocumentStatus.open)
                          .length ??
                      0,
                  collapsedChildrenCount:
                      children
                          ?.where(
                            (c) => c.status == hc.DocumentStatus.collapsed,
                          )
                          .length ??
                      0,
                  onFocus: _onBlockFocus,
                  onControllerReady: _registerController,
                  onChanged: (final content) =>
                      _replaceBlock(index, block.copyWith(content: content)),
                  onOpenChild: children == null || children.isEmpty
                      ? null
                      : () => _openChild(children.last),
                );
              },
            ),
          ),
          _SelectionToolbar(
            onDiscuss: () {
              final index = _lastFocusedBlockIndex;
              if (index == null) return;
              unawaited(_discussBlock(index));
            },
            onAskAi: _onAskAi,
            onApplyConclusion: _path.length > 1
                ? () => unawaited(_collapseCurrent(rewriteFromDiscussion: true))
                : null,
            onExpand: () {}, // placeholder
            onSummarise: () {}, // placeholder
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({
    required this.path,
    required this.labelBuilder,
    required this.onTap,
    required this.onCollapse,
  });
  final List<hc.DocumentNode> path;
  final String Function(hc.DocumentNode node) labelBuilder;
  final void Function(int index) onTap;
  final VoidCallback onCollapse;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: path.length > 1 ? () => onTap(path.length - 2) : null,
              icon: const Icon(Icons.arrow_upward, size: 18),
              tooltip: 'Climb up',
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < path.length; i++) ...[
                      if (i > 0)
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: i == path.length - 1 ? null : () => onTap(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Text(
                            labelBuilder(path[i]),
                            style: i == path.length - 1
                                ? theme.textTheme.bodyMedium
                                : theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onCollapse,
              icon: const Icon(Icons.archive_outlined, size: 18),
              tooltip: 'Collapse discussion',
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.onDiscuss,
    required this.onAskAi,
    required this.onExpand,
    required this.onSummarise,
    this.onApplyConclusion,
  });
  final VoidCallback onDiscuss;
  final VoidCallback onAskAi;
  final VoidCallback onExpand;
  final VoidCallback onSummarise;

  /// "Apply conclusion" — rewrite the head span from this discussion and
  /// collapse (ADR 0001). Only available when inside a discussion child.
  final VoidCallback? onApplyConclusion;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Discuss the focused block',
              child: TextButton.icon(
                onPressed: onDiscuss,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Discuss'),
              ),
            ),
            Tooltip(
              message: 'Ask AI at the cursor position',
              child: TextButton.icon(
                onPressed: onAskAi,
                icon: const Icon(Icons.smart_toy_outlined, size: 18),
                label: const Text('Ask AI'),
              ),
            ),
            onApplyConclusion == null
                ? const SizedBox.shrink()
                : Tooltip(
                    message:
                        'Rewrite the head span from this discussion and collapse',
                    child: TextButton.icon(
                      onPressed: onApplyConclusion,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Apply conclusion'),
                    ),
                  ),
            TextButton.icon(
              onPressed: onExpand,
              icon: const Icon(Icons.unfold_more, size: 18),
              label: const Text('Expand'),
            ),
            TextButton.icon(
              onPressed: onSummarise,
              icon: const Icon(Icons.summarize, size: 18),
              label: const Text('Summarise'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DocBlockTile extends StatefulWidget {
  const _DocBlockTile({
    required this.block,
    required this.blockIndex,
    required this.openChildrenCount,
    required this.collapsedChildrenCount,
    required this.onFocus,
    required this.onControllerReady,
    required this.onChanged,
    required this.onOpenChild,
    super.key,
  });
  final hc.Block block;
  final int blockIndex;
  final int openChildrenCount;
  final int collapsedChildrenCount;
  // ignore: avoid_positional_boolean_parameters
  final void Function(int index, bool hasFocus) onFocus;
  final void Function(int index, TextEditingController controller)
  onControllerReady;
  final ValueChanged<String> onChanged;
  final VoidCallback? onOpenChild;

  @override
  State<_DocBlockTile> createState() => _DocBlockTileState();
}

class _DocBlockTileState extends State<_DocBlockTile> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
    _controller.selection = TextSelection.collapsed(
      offset: widget.block.content.length,
    );
    _focusNode.addListener(_reportFocus);
    widget.onControllerReady(widget.blockIndex, _controller);
  }

  void _reportFocus() => widget.onFocus(widget.blockIndex, _focusNode.hasFocus);

  @override
  void didUpdateWidget(final _DocBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.id != widget.block.id ||
        oldWidget.block.content != widget.block.content) {
      _controller.text = widget.block.content;
      _controller.selection = TextSelection.collapsed(
        offset: widget.block.content.length,
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_reportFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isHeading = widget.block.type == hc.BlockType.heading;
    final isList = widget.block.type == hc.BlockType.list;
    final hasChildren =
        widget.openChildrenCount > 0 || widget.collapsedChildrenCount > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasChildren)
          IconButton(
            key: const ValueKey('open-child-button'),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: widget.onOpenChild,
            icon: Badge(
              isLabelVisible: widget.openChildrenCount > 0,
              label: Text('${widget.openChildrenCount}'),
              child: Icon(
                widget.openChildrenCount > 0
                    ? Icons.chat_bubble_outline
                    : Icons.check_circle_outline,
              ),
            ),
            tooltip: widget.openChildrenCount > 0
                ? 'Open discussion'
                : 'Archived discussion',
          ),
        if (isList)
          const Padding(
            padding: EdgeInsets.only(top: 12, right: 8),
            child: Text('•'),
          ),
        Expanded(
          child: TextField(
            key: ValueKey(widget.block.id),
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: isHeading ? 'Heading' : null,
            ),
            style: isHeading
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        (theme.textTheme.titleMedium?.fontSize ?? 16) +
                        (widget.block.level != null
                            ? (4 - (widget.block.level!.clamp(1, 4)))
                            : 0),
                  )
                : theme.textTheme.bodyMedium,
            maxLines: isHeading ? 1 : null,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
