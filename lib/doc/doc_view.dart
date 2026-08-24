import 'package:lastanswer/common_imports.dart';

/// Recursive document editor (ADR 0001).
///
/// Renders [doc] blocks as an editable list. Any block can be discussed:
/// "Discuss" creates a child [ProjectModelDoc] anchored to that block
/// (with a snapshot of its content) and dives into it. Navigation uses an
/// internal back-stack ([_path]) with breadcrumbs; collapsed discussions are
/// archived, never deleted.
class DocView extends StatefulWidget {
  const DocView({required this.doc, super.key});
  final ProjectModelDoc doc;

  @override
  State<DocView> createState() => _DocViewState();
}

class _DocViewState extends State<DocView> {
  /// Root first, currently open document last.
  late List<ProjectModelDoc> _path;
  int? _lastFocusedBlockIndex;

  /// Open/collapsed discussion children of the current node, by anchor block.
  Map<DocBlockId, List<ProjectModelDoc>> _childrenByBlock = {};

  /// Text controllers of visible blocks, for cursor-positioned AI writes.
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _path = [widget.doc];
    _reloadChildren();
  }

  @override
  void didUpdateWidget(final DocView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doc != widget.doc && _path.length == 1) {
      setState(() => _path[0] = widget.doc);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  ProjectModelDoc get _current => _path.last;

  Future<void> _reloadChildren() async {
    final repository = context.read<ProjectsRepository>();
    final children = await repository.getChildren(parentDocId: _current.id);
    if (!mounted) return;
    setState(() {
      _childrenByBlock = <DocBlockId, List<ProjectModelDoc>>{};
      for (final child in children.whereType<ProjectModelDoc>()) {
        final blockId = child.anchorSpan?.blockId;
        if (blockId == null) continue;
        _childrenByBlock.putIfAbsent(blockId, () => []).add(child);
      }
    });
  }

  Future<void> _persist(final ProjectModelDoc node) async {
    setState(() => _path[_path.length - 1] = node);
    if (_path.length == 1) {
      context.read<OpenedProjectNotifier>().updateProject(node);
    } else {
      await context.read<ProjectsRepository>().put(project: node);
    }
  }

  Future<void> _replaceBlock(final int index, final DocBlockModel block) async {
    final blocks = List<DocBlockModel>.from(_current.blocks);
    if (index < 0 || index >= blocks.length) return;
    blocks[index] = block;
    await _persist(
      _current.copyWith(blocks: blocks, updatedAt: DateTime.now()),
    );
  }

  void _onBlockFocus(final int index, final bool hasFocus) {
    if (hasFocus) _lastFocusedBlockIndex = index;
  }

  void _registerController(final int index, final TextEditingController c) {
    _controllers[index] = c;
  }

  /// Dives into the given child discussion document.
  Future<void> _openChild(final ProjectModelDoc child) async {
    setState(() {
      _path.add(child);
      _lastFocusedBlockIndex = null;
    });
    await _reloadChildren();
  }

  /// Climbs one level up the back-stack.
  Future<void> _climbUp() async {
    if (_path.length <= 1) return;
    setState(() {
      _path.removeLast();
      _lastFocusedBlockIndex = null;
    });
    await _reloadChildren();
  }

  /// Creates a discussion child anchored to the block at [index] and dives in.
  Future<void> _discussBlock(final int index) async {
    final block = _current.blocks[index];
    final child = ProjectModelDoc(
      id: ProjectModelId.generate(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: '',
      parentDocId: _current.id,
      anchorSpan: AnchorSpanModel(blockId: block.id),
      spanSnapshot: block.content,
      blocks: [
        DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
      ],
    );
    await context.read<ProjectsRepository>().put(project: child);
    await _openChild(child);
  }

  /// Collapses the current discussion: archives it and climbs back to head.
  Future<void> _collapseCurrent() async {
    if (_path.length <= 1) return;
    await _persist(
      _current.copyWith(status: DocStatus.collapsed, updatedAt: DateTime.now()),
    );
    await _climbUp();
  }

  String _breadcrumbLabel(final ProjectModelDoc node) {
    if (node.title.isNotEmpty) return node.title;
    final snapshot = node.spanSnapshot.trim();
    if (snapshot.isNotEmpty) {
      return snapshot.length <= 32
          ? snapshot
          : '${snapshot.substring(0, 32)}…';
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
      final text = '$prefix${buffer.toString()}$suffix';
      controller
        ..text = text
        ..selection = TextSelection.collapsed(offset: prefix.length + buffer.length);
    }
    await _replaceBlock(index!, _current.blocks[index].copyWith(content: controller.text));
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
                  _path.removeLast();
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
                      children?.where((c) => c.status == DocStatus.open).length ?? 0,
                  collapsedChildrenCount:
                      children?.where((c) => c.status == DocStatus.collapsed).length ?? 0,
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
  final List<ProjectModelDoc> path;
  final String Function(ProjectModelDoc node) labelBuilder;
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
  });
  final VoidCallback onDiscuss;
  final VoidCallback onAskAi;
  final VoidCallback onExpand;
  final VoidCallback onSummarise;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: onDiscuss,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Discuss'),
            ),
            TextButton.icon(
              onPressed: onAskAi,
              icon: const Icon(Icons.smart_toy_outlined, size: 18),
              label: const Text('Ask AI'),
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
  final DocBlockModel block;
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
    final isHeading = widget.block.type == DocBlockType.heading;
    final isList = widget.block.type == DocBlockType.list;
    final hasChildren =
        widget.openChildrenCount > 0 || widget.collapsedChildrenCount > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasChildren)
          IconButton(
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
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
