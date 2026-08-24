import 'chat_document_service.dart';
import 'document_node.dart';
import 'document_repository.dart';
import 'in_memory_document_repository.dart';

/// Deterministic scripted response for one prompt.
final class ScriptedAgentResponse {
  const ScriptedAgentResponse({
    required this.match,
    this.chunks = const [],
    this.response,
    this.error,
  });

  final bool Function(String prompt) match;
  final List<String> chunks;
  final String? response;
  final Object? error;
}

/// UI-free and LLM-free integration harness for chat documents.
///
/// It uses the same document APIs and lifecycle as the app: install, spawn,
/// create sessions, stream turns into persisted blocks, fail them, switch
/// sessions, and anchor child threads. The transport is deterministic; the
/// orchestration is real.
final class HeadlessAgentHarness {
  HeadlessAgentHarness({
    this.responses = const [],
    DocumentRepository? repository,
  }) : repository = repository ?? InMemoryDocumentRepository() {
    chat = ChatDocumentService(repository: this.repository);
  }

  final List<ScriptedAgentResponse> responses;
  final DocumentRepository repository;
  late final ChatDocumentService chat;

  DocumentNode? current;
  String? sessionId;
  final List<String> prompts = [];
  bool _isInstalled = false;
  bool _isStarted = false;
  final Set<String> _sessionIds = {};
  final List<String> _workingDirectories = [];
  int _blockNumber = 0;

  bool get isReady => _isInstalled && _isStarted && sessionId != null;

  Future<DocumentNode> createChat([String title = 'Chat']) async {
    final node = await chat.createChat(title);
    current = node;
    return node;
  }

  Future<void> install() async {
    _isInstalled = true;
  }

  Future<void> start(String workingDirectory) async {
    if (!_isInstalled) throw StateError('ACP client is not installed');
    if (_isStarted) return;
    _isStarted = true;
    await newSession(workingDirectory);
  }

  Future<String> newSession(String workingDirectory) async {
    if (!_isInstalled || !_isStarted) {
      throw StateError('ACP client is not started');
    }
    _workingDirectories.add(workingDirectory);
    sessionId = 'session-${_sessionIds.length + 1}';
    _sessionIds.add(sessionId!);
    return sessionId!;
  }

  void switchTo(String id) {
    if (!_sessionIds.contains(id)) throw StateError('Unknown session: $id');
    sessionId = id;
  }

  Future<void> stop() async {
    _isStarted = false;
    _sessionIds.clear();
    sessionId = null;
  }

  Stream<String> send(
    String text, {
    String? sessionId,
    String? workingDirectory,
  }) async* {
    final activeSessionId = sessionId ?? this.sessionId;
    if (!_isInstalled) throw StateError('ACP client is not installed');
    if (!_isStarted || activeSessionId == null) {
      throw StateError('ACP session is not ready');
    }
    prompts.add(text);
    final response = responses.firstWhere(
      (response) => response.match(text),
      orElse: () => ScriptedAgentResponse(match: (_) => true, chunks: [text]),
    );
    if (response.error != null) throw response.error!;
    for (final chunk in response.chunks) {
      await Future<void>.delayed(Duration.zero);
      yield chunk;
    }
  }

  Future<DocumentNode> sendUserMessage(String text) async {
    await _requireChat();
    await reload(current!.id);
    final nodeId = current!.id;
    await chat.appendMessage(nodeId, role: ChatRole.user, content: text);
    final assistantBlockId = NodeId('assistant-block-${++_blockNumber}');
    var buffer = StringBuffer();
    try {
      await for (final delta in send(text)) {
        buffer.write(delta);
        final nextAssistantId = await _upsertAssistant(
          nodeId,
          blockId: assistantBlockId,
          content: '$buffer',
        );
      }
      await chat.updateMessageStatus(
        nodeId,
        assistantBlockId,
        status: MessageStatus.complete,
      );
    } on Object {
      try {
        await chat.updateMessageStatus(
          nodeId,
          assistantBlockId,
          status: MessageStatus.failed,
        );
      } on StateError {
        await chat.appendMessage(
          nodeId,
          role: ChatRole.assistant,
          content: '',
          blockId: NodeId('message:${assistantBlockId.value}'),
          status: MessageStatus.failed,
        );
      }
      await reload(nodeId);
      rethrow;
    }
    await reload(nodeId);
    return current!;
  }

  Future<NodeId> _upsertAssistant(
    NodeId nodeId, {
    required NodeId blockId,
    required String content,
  }) async {
    final result = await repository.get(nodeId);
    final node = switch (result) {
      DocFound(:final node) => node,
      _ => null,
    };
    if (node == null) throw StateError('chat $nodeId not found');
    final exists = node.blockById(blockId);
    if (exists == null) {
      final block = await chat.appendMessage(
        nodeId,
        role: ChatRole.assistant,
        content: content,
        blockId: blockId,
        status: MessageStatus.streaming,
      );
      return block.id;
    }
    await chat.replaceMessage(nodeId, blockId, content: content);
    return blockId;
  }

  Future<void> reload(NodeId id) async {
    final result = await repository.get(id);
    if (result case final DocFound found) current = found.node;
  }

  Future<void> _requireChat() async {
    if (current == null || !_isInstalled || !_isStarted || sessionId == null) {
      throw StateError('headless chat requires install(), start(), and a chat');
    }
  }
}
