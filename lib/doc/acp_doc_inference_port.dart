import 'package:core/core.dart';
import 'package:xsoulspace_inference_acp/xsoulspace_inference_acp.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

/// Configuration for an ACP agent executable.
///
/// The executable is spawned only when inference is requested.
class AcpAgentConfig {
  const AcpAgentConfig({
    required this.command,
    this.arguments = const [],
    this.workingDirectory,
  });

  final String command;
  final List<String> arguments;
  final String? workingDirectory;
}

/// Adapts ACP structured-text streaming to [DocInferencePort].
class AcpDocInferencePort implements DocInferencePort {
  AcpDocInferencePort({this.client, this.config});

  final StructuredTextStreamingInferenceClient? client;
  final AcpAgentConfig? config;

  StructuredTextStreamingInferenceClient get _effectiveClient {
    final existing = client;
    if (existing != null) return existing;
    final agentConfig = config;
    if (agentConfig == null) {
      throw StateError('An ACP client or agent configuration is required');
    }
    return AcpInferenceClient(
      command: agentConfig.command,
      arguments: agentConfig.arguments,
      workingDirectory: agentConfig.workingDirectory,
    );
  }

  @override
  Stream<String> chat(final List<ChatMessage> messages) async* {
    final session = await _effectiveClient.streamStructuredText(
      InferenceRequest(prompt: _buildPrompt(messages)),
    );
    try {
      await for (final event in session.events) {
        if (event.type ==
                InferenceStructuredTextStreamEventType.partialOutput &&
            event.textDelta != null) {
          yield event.textDelta!;
        }
      }
    } finally {
      await session.dispose();
    }
  }

  static String _buildPrompt(final List<ChatMessage> messages) {
    final buffer = StringBuffer();
    for (final message in messages) {
      buffer
        ..write(message.role)
        ..writeln(':')
        ..writeln(message.content)
        ..writeln();
    }
    return buffer.toString().trimRight();
  }
}
