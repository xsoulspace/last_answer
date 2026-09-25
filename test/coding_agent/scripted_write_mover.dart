import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

/// The scripted mover (LLM-free): one `write` tool call, then done. The
/// write is GATED — with the host's permission delegate wired, the daemon
/// routes every write through `session/request_permission`.
final class ScriptedWriteMover implements GenerationHandler {
  ScriptedWriteMover(this.path, this.content);

  final String path;
  final String content;
  bool wrote = false;

  @override
  Future<ActorGenerateResponse> generate(
    final World world,
    final ActorGenerateRequest request,
  ) async {
    final calls = wrote
        ? const <ToolCall>[]
        : [
            ToolCall(
              name: const ToolName('write'),
              arguments: {'path': path, 'content': content},
            ),
          ];
    wrote = true;
    final text = calls.isEmpty ? 'done' : 'writing';
    final response = ActorGenerateResponse(
      actorEntity: request.actorEntity,
      structuredOutput: {'text': text},
      rawOutput: text,
      toolCalls: calls,
      taskId: request.taskId,
    );
    world.events.writer<ActorGenerateResponse>().send(response);
    return response;
  }
}
