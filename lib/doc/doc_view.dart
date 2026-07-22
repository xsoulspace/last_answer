import 'package:lastanswer/common_imports.dart';

/// Document editor view for GDD/PRD. Renders [doc.blocks] as editable list;
/// on any block change calls [OpenedProjectNotifier.updateProject] to persist.
class DocView extends StatefulWidget {
  const DocView({required this.doc, super.key});
  final ProjectModelDoc doc;

  @override
  State<DocView> createState() => _DocViewState();
}

class _DocViewState extends State<DocView> {
  late ProjectModelDoc _doc;
  int? _focusedBlockIndex;
  SpanId? _threadPanelSpanId;

  @override
  void initState() {
    super.initState();
    _doc = widget.doc;
  }

  @override
  void didUpdateWidget(final DocView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doc != widget.doc) _doc = widget.doc;
  }

  void _updateDoc(final ProjectModelDoc updated) {
    setState(() => _doc = updated);
    context.read<OpenedProjectNotifier>().updateProject(updated);
  }

  void _replaceBlock(final int index, final DocBlockModel newBlock) {
    final blocks = List<DocBlockModel>.from(_doc.blocks);
    if (index < 0 || index >= blocks.length) return;
    blocks[index] = newBlock;
    _updateDoc(_doc.copyWith(blocks: blocks, updatedAt: DateTime.now()));
  }

  void _onBlockFocus(final int index, final bool hasFocus) {
    setState(() => _focusedBlockIndex = hasFocus ? index : null);
  }

  void _openDiscuss() {
    if (_focusedBlockIndex == null) return;
    final blockId = _doc.blocks[_focusedBlockIndex!].id;
    final spanId = SpanId.forBlock(blockId);
    final threads = Map<SpanId, DocThreadModel>.from(_doc.threads);
    threads.putIfAbsent(spanId, () => const DocThreadModel(messages: []));
    _updateDoc(_doc.copyWith(threads: threads, updatedAt: DateTime.now()));
    setState(() => _threadPanelSpanId = spanId);
  }

  void _closeThreadPanel() => setState(() => _threadPanelSpanId = null);

  void _addThreadMessage(final String content) {
    final spanId = _threadPanelSpanId;
    if (spanId == null) return;
    final thread = _doc.threads[spanId] ?? const DocThreadModel(messages: []);
    final messages = [
      ...thread.messages,
      DocThreadMessageModel(content: content, timestamp: DateTime.now()),
    ];
    final threads = Map<SpanId, DocThreadModel>.from(_doc.threads);
    threads[spanId] = DocThreadModel(messages: messages);
    _updateDoc(_doc.copyWith(threads: threads, updatedAt: DateTime.now()));
  }

  void _onAskAi() {
    final port = context.read<DocInferencePort?>();
    if (port == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No provider configured')));
      return;
    }
    // Placeholder: could pass selected text as user message
  }

  @override
  Widget build(final BuildContext context) => PopScope(
    onPopInvoked: (_) => context.read<OpenedProjectNotifier>().onPopProject(),
    child: Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: _doc.blocks.length,
          itemBuilder: (final context, final index) => _DocBlockTile(
            block: _doc.blocks[index],
            blockIndex: index,
            hasThread: _doc.threads.containsKey(
              SpanId.forBlock(_doc.blocks[index].id),
            ),
            isFocused: _focusedBlockIndex == index,
            onFocus: _onBlockFocus,
            onChanged: (final content) => _replaceBlock(
              index,
              _doc.blocks[index].copyWith(content: content),
            ),
            onThreadTap: () => setState(
              () => _threadPanelSpanId = SpanId.forBlock(_doc.blocks[index].id),
            ),
          ),
        ),
        if (_focusedBlockIndex != null)
          _SelectionToolbar(
            onDiscuss: _openDiscuss,
            onAskAi: _onAskAi,
            onExpand: () {}, // placeholder
            onSummarise: () {}, // placeholder
          ),
        if (_threadPanelSpanId != null)
          _ThreadPanel(
            thread:
                _doc.threads[_threadPanelSpanId] ??
                const DocThreadModel(messages: []),
            onClose: _closeThreadPanel,
            onSend: _addThreadMessage,
          ),
      ],
    ),
  );
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
  Widget build(final BuildContext context) => Positioned(
    left: 24,
    right: 24,
    bottom: 16,
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

class _ThreadPanel extends StatefulWidget {
  const _ThreadPanel({
    required this.thread,
    required this.onClose,
    required this.onSend,
  });
  final DocThreadModel thread;
  final VoidCallback onClose;
  final ValueChanged<String> onSend;

  @override
  State<_ThreadPanel> createState() => _ThreadPanelState();
}

class _ThreadPanelState extends State<_ThreadPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Material(
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.chat_bubble),
                ),
                const Expanded(child: Text('Thread')),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.thread.messages.length,
                itemBuilder: (final context, final i) {
                  final m = widget.thread.messages[i];
                  return ListTile(
                    dense: true,
                    title: Text(m.content),
                    subtitle: Text(
                      m.authorName.isEmpty ? 'User' : m.authorName,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (final text) {
                        if (text.trim().isEmpty) return;
                        widget.onSend(text.trim());
                        _controller.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final t = _controller.text.trim();
                      if (t.isEmpty) return;
                      widget.onSend(t);
                      _controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
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
    required this.hasThread,
    required this.isFocused,
    required this.onFocus,
    required this.onChanged,
    required this.onThreadTap,
  });
  final DocBlockModel block;
  final int blockIndex;
  final bool hasThread;
  final bool isFocused;
  final void Function(int index, bool hasFocus) onFocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onThreadTap;

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
    _focusNode.removeListener(_reportFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isHeading = widget.block.type == DocBlockType.heading;
    final isList = widget.block.type == DocBlockType.list;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isList)
            const Padding(
              padding: EdgeInsets.only(top: 12, right: 8),
              child: Text('•'),
            ),
          Expanded(
            child: TextField(
              key: ValueKey(widget.block.id.value),
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
          if (widget.hasThread)
            IconButton(
              iconSize: 18,
              onPressed: widget.onThreadTap,
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Open thread',
            ),
        ],
      ),
    );
  }
}
