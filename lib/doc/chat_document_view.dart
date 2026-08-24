import 'package:file_selector/file_selector.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/common_imports.dart';
import 'package:uuid/uuid.dart';

import 'package:lastanswer/doc/acp_agent_runtime.dart';

const _uuid = Uuid();

hc.NodeId _nextNodeId() => hc.NodeId(_uuid.v4());

class ChatDocumentView extends StatefulWidget {
  const ChatDocumentView({required this.doc, super.key});

  final ProjectModelDoc doc;

  @override
  State<ChatDocumentView> createState() => _ChatDocumentViewState();
}

class _ChatDocumentViewState extends State<ChatDocumentView> {
  final _composerController = TextEditingController();
  final List<hc.DocumentNode> _path = [];
  final Map<int, TextEditingController> _messageControllers = {};
  bool _isSyncingControllers = false;
  StreamSubscription<AcpPromptUpdate>? _streamSubscription;
  bool _isSending = false;
  List<AcpAgentInstallation> _installations = [];
  AcpAgentInstallation? _selectedInstallation;
  hc.DocumentNode get _current => _path.last;

  hc.ChatDocumentService get _chatService =>
      context.read<hc.ChatDocumentService>();
  AcpAgentRuntime get _runtime => context.read<AcpAgentRuntime>();
  AcpInstallationService get _installationService =>
      context.read<AcpInstallationService>();

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final repository = context.read<hc.DocumentRepository>();
    final result = await repository.get(hc.NodeId(widget.doc.id.value));
    final node = switch (result) {
      final hc.DocFound found => found.node,
      _ => hc.DocumentNode(
        id: hc.NodeId(widget.doc.id.value),
        formatId: DocFormatIds.chat,
        blocks: [
          hc.Block(
            id: _nextNodeId(),
            type: hc.BlockType.heading,
            content: widget.doc.title,
            level: 1,
          ),
        ],
        createdAt: widget.doc.createdAt,
        updatedAt: widget.doc.updatedAt,
      ),
    };
    if (!mounted) return;
    setState(() => _path.add(node));
    if (_path.length == 1) await _persistRoot(_current);
    await _detectAgents();
  }

  Future<void> _detectAgents() async {
    try {
      final installations = await _installationService.detectAll();
      if (!mounted) return;
      setState(() {
        _installations = installations;
        _selectedInstallation = installations.isEmpty
            ? null
            : installations.first;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _installations = [];
        _selectedInstallation = null;
      });
    }
  }

  Future<void> _ensureSession() async {
    if (_runtime.isReady && _runtime.currentSessionId != null) return;
    final installation = _selectedInstallation;
    if (installation == null) {
      throw StateError('No ACP agent detected');
    }
    await _runtime.start(AcpRuntimeConfig.fromInstallation(installation));
    final sessionId = await _runtime.newSession(Directory.current.path);
    if (_path.isNotEmpty) {
      final titleBlock = _current.blocks.first.copyWith(sessionId: sessionId);
      await _replaceBlocks([titleBlock, ..._current.blocks.skip(1)]);
    }
  }

  Future<void> _persistRoot(hc.DocumentNode node) async {
    final repository = context.read<hc.DocumentRepository>();
    await repository.save(node);
    final stub = ProjectModelDoc(
      id: ProjectModelId(node.id.value),
      createdAt: node.createdAt,
      updatedAt: node.updatedAt,
      formatId: DocFormatIds.chat,
      title: node.blocks.firstOrNull?.content ?? '',
      blocks: const [],
    );
    if (mounted) context.read<OpenedProjectNotifier>().updateProject(stub);
  }

  Future<void> _replaceBlocks(List<hc.Block> blocks) async {
    final updated = _current.withBlocks(blocks);
    setState(() => _path[_path.length - 1] = updated);
    await _chatService.repository.save(updated);
    if (_path.length == 1)
      await _persistRoot(updated);
    else {
      final parentIndex = _path.length - 2;
      await _chatService.repository.save(_path[parentIndex]);
    }
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _isSending || !mounted) return;
    setState(() => _isSending = true);
    _composerController.clear();
    try {
      await _ensureSession();
      final userBlockId = _nextNodeId();
      final assistantBlockId = _nextNodeId();
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.user,
        content: text,
        blockId: userBlockId,
      );
      await _reloadCurrent();
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.assistant,
        content: '',
        blockId: assistantBlockId,
        status: hc.MessageStatus.streaming,
      );
      await _reloadCurrent();
      final buffer = StringBuffer();
      final stream = _runtime.send(text);
      _streamSubscription = stream.listen(
        (update) {
          if (update.textDelta != null)
            buffer.write(update.textDelta!);
          else if (update.message != null)
            buffer.writeln('[tool] ${update.message}');
          unawaited(_updateAssistant(buffer.toString(), assistantBlockId));
        },
        onDone: () async {
          await _finishAssistant(buffer, assistantBlockId);
        },
        onError: (Object _) async {
          await _failAssistant(assistantBlockId, buffer);
        },
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _updateAssistant(String content, hc.NodeId blockId) async {
    await _safeReplaceMessage(blockId, content);
  }

  Future<void> _finishAssistant(StringBuffer buffer, hc.NodeId blockId) async {
    await _safeReplaceMessage(blockId, buffer.toString());
    await _chatService.updateMessageStatus(
      _current.id,
      blockId,
      status: hc.MessageStatus.complete,
    );
    if (mounted) unawaited(_reloadCurrent());
    _streamSubscription = null;
  }

  Future<void> _failAssistant(hc.NodeId blockId, StringBuffer buffer) async {
    await _safeReplaceMessage(blockId, '${buffer}\n[failed]');
    await _chatService.updateMessageStatus(
      _current.id,
      blockId,
      status: hc.MessageStatus.failed,
    );
    if (mounted) unawaited(_reloadCurrent());
    _streamSubscription = null;
  }

  Future<void> _safeReplaceMessage(hc.NodeId blockId, String content) async {
    try {
      await _chatService.replaceMessage(_current.id, blockId, content: content);
    } on StateError {
      // The current path changed before a late stream event arrived.
    }
  }

  Future<void> _reloadCurrent() async {
    final result = await _chatService.repository.get(_current.id);
    if (!mounted) return;
    if (result case final hc.DocFound found) {
      setState(() => _path[_path.length - 1] = found.node);
    }
  }

  Future<void> _climbUp() async {
    if (_path.length <= 1) return;
    setState(() => _path.removeLast());
    await _reloadCurrent();
  }

  void _stop() {
    _runtime.cancel();
    unawaited(_streamSubscription?.cancel());
    _streamSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_streamSubscription?.cancel());
    for (final controller in _messageControllers.values) {
      controller.dispose();
    }
    _composerController.dispose();
    super.dispose();
  }

  String get _statusLabel => switch (_runtime.status) {
    AcpRuntimeStatus.ready => 'Ready',
    AcpRuntimeStatus.starting => 'Starting',
    AcpRuntimeStatus.error => 'Error',
    AcpRuntimeStatus.stopped => 'Stopped',
    AcpRuntimeStatus.idle => 'Idle',
  };

  @override
  Widget build(BuildContext context) {
    if (_path.isEmpty) return const Center(child: CircularProgressIndicator());
    final messages = [
      for (final block in _current.blocks)
        if (block.type == hc.BlockType.message) block,
    ];
    return PopScope(
      canPop: _path.length == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_climbUp());
      },
      child: Column(
        children: [
          if (_path.length > 1)
            Row(
              children: [
                IconButton(onPressed: _climbUp, icon: Icon(Icons.arrow_back)),
                Expanded(
                  child: Text(
                    _current.spanSnapshot ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: Colors.greenAccent),
                Gap(6),
                Text('ACP $_statusLabel'),
                Spacer(),
                DropdownButton<AcpAgentInstallation>(
                  value: _selectedInstallation,
                  hint: Text('Select agent'),
                  items: [
                    for (final installation in _installations)
                      DropdownMenuItem(
                        value: installation,
                        child: Text(installation.entry.displayName),
                      ),
                  ],
                  onChanged: _isSending
                      ? null
                      : (v) => setState(() => _selectedInstallation = v),
                ),
                if (_installations.isEmpty)
                  IconButton(
                    onPressed: _showInstallHelp,
                    icon: Icon(Icons.download_outlined),
                  ),
                IconButton(
                  onPressed: _isSending ? null : _useLocalClient,
                  tooltip: 'Use local executable',
                  icon: Icon(Icons.folder_open),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.role == hc.ChatRole.user;
                final controller = _messageControllers.putIfAbsent(index, () {
                  final value = TextEditingController(text: message.content);
                  value.addListener(() {
                    if (_isSyncingControllers) return;
                    final text = value.text;
                    if (text != message.content) {
                      unawaited(_replaceMessage(message.id, text));
                    }
                  });
                  return value;
                });
                if (controller.text != message.content) {
                  _isSyncingControllers = true;
                  controller.text = message.content;
                  _isSyncingControllers = false;
                }
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(maxWidth: 560),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          key: ValueKey(message.id.value),
                          controller: controller,
                          minLines: 1,
                          maxLines: null,
                          decoration: const InputDecoration.collapsed(
                            hintText: '',
                          ),
                        ),
                        Wrap(
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  unawaited(_discussMessage(message)),
                              label: Text('Discuss'),
                              icon: Icon(Icons.chat_bubble_outline, size: 18),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                unawaited(
                                  Clipboard.setData(
                                    ClipboardData(text: message.content),
                                  ),
                                );
                              },
                              label: Text('Copy'),
                              icon: Icon(Icons.copy, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    minLines: 1,
                    maxLines: 6,
                  ),
                ),
                if (_isSending)
                  IconButton.filledTonal(
                    onPressed: _stop,
                    icon: Icon(Icons.stop),
                  )
                else
                  IconButton.filled(onPressed: _send, icon: Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _replaceMessage(hc.NodeId blockId, String content) async {
    try {
      await _chatService.replaceMessage(_current.id, blockId, content: content);
    } on StateError {
      return;
    }
    await _safeReloadWithoutControllers();
  }

  Future<void> _safeReloadWithoutControllers() async {
    final result = await _chatService.repository.get(_current.id);
    if (!mounted) return;
    if (result case final hc.DocFound found) {
      setState(() => _path[_path.length - 1] = found.node);
    }
  }

  Future<void> _discussMessage(hc.Block message) async {
    final child = await _chatService.startAgentThread(
      parentNodeId: _current.id,
      anchorBlockId: message.id,
      title: message.content.isEmpty ? 'Discussion' : message.content,
    );
    if (!mounted) return;
    setState(() => _path.add(child));
  }

  Future<void> _showInstallHelp() async {
    final commands = AcpAgentCatalog.defaultEntries
        .map((e) => e.installCommand ?? [])
        .where((c) => c.isNotEmpty)
        .map((c) => c.join(' '));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Install an ACP agent'),
        content: SelectableText(commands.join('\n')),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_detectAgents());
            },
            child: Text('Recheck'),
          ),
        ],
      ),
    );
  }

  Future<void> _useLocalClient() async {
    final file = await openFile(
      acceptedTypeGroups: [const XTypeGroup(label: 'Executables')],
    );
    if (file == null) return;
    final installation = await _installationService.detectLocalPath(file.path);
    if (!mounted) return;
    if (installation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Executable not found')));
      return;
    }
    setState(() {
      _installations = [..._installations, installation];
      _selectedInstallation = installation;
    });
  }
}
