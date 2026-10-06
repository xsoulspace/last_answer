import 'package:core/core.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart';

/// Hosted chat-completions lane for [DocInferencePort]: renders the
/// conversation through [OpenRouterInferenceClient] with the system message
/// as a native system prompt and prior assistant turns as native assistant
/// messages (the context-fragment wire contract).
///
/// The port yields the completed reply as one delta — the transport is a
/// single HTTP round trip; no fake per-word streaming is invented.
final class OpenRouterDocInferencePort implements DocInferencePort {
  OpenRouterDocInferencePort({
    required this._apiKey,
    required this.model,
    this._baseUrl,
    final OpenRouterInferenceClient? client,
  }) : _injectedClient = client;

  final String _apiKey;
  final String? _baseUrl;
  final OpenRouterInferenceClient? _injectedClient;

  /// OpenRouter model id, e.g. `anthropic/claude-sonnet-4.5`.
  final String model;

  OpenRouterInferenceClient? _client;

  OpenRouterInferenceClient get _effectiveClient {
    final injected = _injectedClient;
    if (injected != null) return injected;
    final existing = _client;
    if (existing != null) return existing;
    return _client = OpenRouterInferenceClient(
      apiKey: _apiKey,
      defaultModel: model,
      baseUrl: switch (_baseUrl) {
        null || '' => 'https://openrouter.ai/api/v1',
        final url => url,
      },
    );
  }

  @override
  Stream<String> chat(final List<ChatMessage> messages) async* {
    final system = messages
        .where((message) => message.role == 'system')
        .map((message) => message.content)
        .join('\n\n');
    final turns = messages
        .where((message) => message.role != 'system')
        .toList();
    final prompt = turns.isNotEmpty && turns.last.role == 'user'
        ? turns.last.content
        : '';
    final history = prompt.isEmpty ? turns : turns.sublist(0, turns.length - 1);
    final fragments = [
      for (final message in history)
        message.role == 'assistant'
            ? 'asst:${message.content}'
            : message.content,
    ];
    final result = await _effectiveClient.infer(
      InferenceRequest(
        prompt: prompt,
        systemPrompt: system,
        contextFragments: fragments,
      ),
    );
    if (!result.success) {
      final error = result.error;
      throw StateError(
        'openrouter ${error?.code ?? 'unknown'}: ${error?.message ?? ''}',
      );
    }
    final text = result.data?.rawOutput ?? '';
    if (text.isNotEmpty) yield text;
  }
}
