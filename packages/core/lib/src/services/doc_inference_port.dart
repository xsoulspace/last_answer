/// Message for chat-style inference (e.g. Ask AI).
class ChatMessage {
  const ChatMessage({required this.role, required this.content});
  final String role; // e.g. 'user', 'assistant'
  final String content;
}

/// Port for doc inference (Ask AI, Expand, Summarise). No implementation in this app;
/// wire a provider when a backend is available.
abstract interface class DocInferencePort {
  /// Streams assistant reply tokens for the given [messages].
  Stream<String> chat(List<ChatMessage> messages);
}
