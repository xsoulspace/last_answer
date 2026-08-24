import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/doc/acp_doc_inference_port.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

class _FakeSession implements InferenceStructuredTextStreamSession {
  const _FakeSession(this._events);

  final Stream<InferenceStructuredTextStreamEvent> _events;

  @override
  Stream<InferenceStructuredTextStreamEvent> get events => _events;

  @override
  Future<InferenceResult<InferenceResponse>> get result async =>
      InferenceResult.ok(const InferenceResponse(task: InferenceTask.text));

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeStreamingClient implements StructuredTextStreamingInferenceClient {
  _FakeStreamingClient(this.session);

  final InferenceStructuredTextStreamSession session;
  InferenceRequest? lastRequest;

  @override
  String get id => 'fake';

  @override
  Set<InferenceTask> get supportedTasks => const {InferenceTask.text};

  @override
  bool get isAvailable => true;

  @override
  Future<bool> refreshAvailability() async => true;

  @override
  Future<void> load() async {}

  @override
  void resetAvailabilityCache() {}

  @override
  Future<InferenceResult<InferenceResponse>> infer(
    final InferenceRequest request, {
    final ToolRegistry? toolRegistry,
  }) async =>
      InferenceResult.ok(const InferenceResponse(task: InferenceTask.text));

  @override
  Future<InferenceStructuredTextStreamSession> streamStructuredText(
    final InferenceRequest request,
  ) async {
    lastRequest = request;
    return session;
  }
}

void main() {
  test('streams partial-output deltas and formats chat roles', () async {
    final events =
        StreamController<InferenceStructuredTextStreamEvent>.broadcast();
    final client = _FakeStreamingClient(_FakeSession(events.stream));
    final port = AcpDocInferencePort(client: client);

    final tokensFuture = port.chat(const [
      ChatMessage(role: 'system', content: 'Be concise'),
      ChatMessage(role: 'user', content: 'Summarise'),
      ChatMessage(role: 'assistant', content: 'Draft'),
    ]).toList();
    await Future<void>.delayed(Duration.zero);
    events.add(
      InferenceStructuredTextStreamEvent(
        type: InferenceStructuredTextStreamEventType.lifecycle,
        timestamp: DateTime.now(),
        lifecycleState: InferenceStructuredTextLifecycleState.started,
      ),
    );
    for (final delta in const ['Hello', ' world']) {
      events.add(
        InferenceStructuredTextStreamEvent(
          type: InferenceStructuredTextStreamEventType.partialOutput,
          timestamp: DateTime.now(),
          textDelta: delta,
        ),
      );
    }
    await events.close();

    expect(await tokensFuture, ['Hello', ' world']);
    expect(
      client.lastRequest?.prompt,
      'system:\nBe concise\n\nuser:\nSummarise\n\nassistant:\nDraft',
    );
  });
}
