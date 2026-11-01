import 'dart:async';
import 'dart:isolate' show RawReceivePort, SendPort;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart'
    show LoraAttachableInferenceClient, NativeLoraAttachment;

/// A scriptable engine: answers infer with a queued plan (text or typed
/// failure), records every request — the honest-response fakes the
/// protocol law needs.
final class _FakeEngine implements InferenceClient {
  _FakeEngine(this._name);

  final String _name;
  final _requests = <InferenceRequest>[];
  final _plan = <Future<InferenceResult<InferenceResponse>> Function(
    InferenceRequest,
  )>[];

  void enqueueText(String text) {
    _plan.add(
      (request) async => InferenceResult.ok(
        InferenceResponse(task: request.task, rawOutput: text),
      ),
    );
  }

  void enqueueFailure(String code, String message) {
    _plan.add(
      (request) async => InferenceResult.fail(code: code, message: message),
    );
  }

  @override
  String get id => _name;
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const <InferenceTask>{
    InferenceTask.text,
  };
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  Future<void> load() async {}
  @override
  void resetAvailabilityCache() {}

  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) {
    final next = _plan.removeAt(0);
    _requests.add(request);
    return next(request);
  }
}

/// An engine whose FIRST call parks on a gate — the proof that the
/// second request queued behind it instead of running concurrently.
final class _GatedEngine implements InferenceClient {
  _GatedEngine(this.gate, this.order);

  final Completer<void> gate;
  final List<String> order;
  int calls = 0;

  @override
  String get id => 'gated';
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const <InferenceTask>{
    InferenceTask.text,
  };
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  Future<void> load() async {}
  @override
  void resetAvailabilityCache() {}

  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) async {
    calls++;
    order.add('start');
    await gate.future;
    order.add('end');
    return InferenceResult.ok(
      InferenceResponse(task: request.task, rawOutput: 'answer $calls'),
    );
  }
}


/// A scripted engine with the runtime-LoRA attach surface — records every
/// attach and infer with their ORDER, so the tests can pin the
/// attach→generate pairing and the skip-when-unchanged law.
final class _AttachableEngine implements LoraAttachableInferenceClient {
  _AttachableEngine({this.attachSupported = true, this.attachFails = false});

  /// Whether the fake dylib carries the attach ABI.
  final bool attachSupported;

  /// When true, every attach throws the native adapter refusal (a bad
  /// file, or a target the checkpoint lacks).
  final bool attachFails;

  final List<String> order = <String>[];
  final List<({String path, double scale})> attaches =
      <({String path, double scale})>[];
  int attachCalls = 0;
  int inferCalls = 0;

  @override
  String get id => 'attachable';
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const <InferenceTask>{
    InferenceTask.text,
  };
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  Future<void> load() async {}
  @override
  void resetAvailabilityCache() {}

  @override
  bool get loraAttachSupported => attachSupported;

  @override
  Future<NativeLoraAttachment> attachLora(
    String adapterPath, {
    double scale = 1.0,
  }) async {
    attachCalls++;
    order.add('attach:$adapterPath@$scale');
    attaches.add((path: adapterPath, scale: scale));
    if (attachFails) {
      throw StateError('adapter targets a missing module');
    }
    return NativeLoraAttachment(digest: 'digest-$attachCalls', applied: 3);
  }

  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) {
    inferCalls++;
    order.add('infer');
    return Future.value(
      InferenceResult.ok(
        InferenceResponse(task: request.task, rawOutput: 'lora answer'),
      ),
    );
  }
}

void main() {
  // The engine isolate's port protocol, run in-process against fake
  // engines (the real spawn is a thin wrapper around BrainEngineServer):
  // id correlation, serial ordering (two bots sharing one engine just
  // queue), the error mapping to the typed brain errors, and the
  // runtime-LoRA attach law (attach BEFORE generate, skip when unchanged,
  // named refusals on an incapable engine or dylib).
  final replies = StreamController<Map<String, Object?>>.broadcast();
  setUpAll(() => addTearDown(replies.close));

  Future<SendPort> serveWith(
    InferenceClient Function(String cast) newClient,
  ) {
    final ready = Completer<SendPort>();
    final port = RawReceivePort((Object? message) {
      if (message is SendPort) {
        if (!ready.isCompleted) ready.complete(message);
      } else if (message is Map) {
        replies.add(Map<String, Object?>.from(message));
      }
    });
    BrainEngineServer.serve(replies: port.sendPort, newClient: newClient);
    return ready.future;
  }

  Map<String, Object?> request(
    int id, {
    String cast = 'qwen',
    List<BrainTurn> turns = const <BrainTurn>[],
    String? loraPath,
    double loraScale = 1.0,
  }) => <String, Object?>{
    'id': id,
    'op': 'generate',
    'cast': cast,
    'system': 'system',
    'turns': [
      for (final turn in turns)
        <String, Object?>{'fromMe': turn.fromMe, 'content': turn.content},
    ],
    'temperature': 0.7,
    'repetitionPenalty': 1.1,
    'loraPath': ?loraPath,
    'loraScale': loraScale,
  };

  test('a generate request round-trips its text and renders the transcript',
      () async {
    final engine = _FakeEngine('fake-qwen')
      ..enqueueText('first word');
    final toServer = await serveWith((cast) => engine);
    toServer.send(
      request(1, turns: const [
        BrainTurn(fromMe: false, content: 'hello bot'),
        BrainTurn(fromMe: true, content: 'hi human'),
      ]),
    );
    final reply = await replies.stream.first;
    expect(reply['id'], 1);
    expect(reply['ok'], isTrue);
    expect(reply['text'], 'first word');

    // The transcript rode the request as chat messages.
    final sent = engine._requests.single;
    expect(sent.messages, hasLength(3));
    expect(sent.messages.first.role.name, 'system');
    expect(sent.messages[1].role.name, 'user');
    expect(sent.messages[1].content, 'hello bot');
    expect(sent.messages[2].role.name, 'assistant');
    expect(sent.messages[2].content, 'hi human');
    // Sampling rides the request.
    expect(sent.temperature, 0.7);
    expect(sent.repetitionPenalty, 1.1);
  });

  test('requests serialize: the slow first job queues the second', () async {
    final order = <String>[];
    final gate = Completer<void>();
    final toServer = await serveWith((cast) => _GatedEngine(gate, order));
    toServer
      ..send(request(1))
      ..send(request(2));
    // A beat to let the first job start: the second must NOT have begun.
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(order, ['start'], reason: 'the second job queued behind the first');
    gate.complete();
    final collected = await replies.stream.take(2).toList();
    expect(collected.map((final r) => r['id']), [1, 2]);
    expect(collected.first['text'], 'answer 1');
    expect(collected.last['text'], 'answer 2');
    // THE LAW: the second job never ran before the first ended.
    expect(order, ['start', 'end', 'start', 'end']);
  });

  test('one engine per cast: the factory runs once per cast', () async {
    var constructions = 0;
    final engine = _FakeEngine('fake-qwen')
      ..enqueueText('a')
      ..enqueueText('b');
    final toServer = await serveWith((cast) {
      constructions++;
      return engine;
    });
    toServer
      ..send(request(1))
      ..send(request(2));
    final collected = await replies.stream.take(2).toList();
    expect(collected.map((final r) => r['text']), ['a', 'b']);
    expect(constructions, 1, reason: 'the weights load once per cast');
  });

  test('typed failures map: unavailable is retryable, engine errors are not',
      () async {
    final engine = _FakeEngine('fake-qwen')
      ..enqueueFailure('unavailable', 'weights not loaded')
      ..enqueueFailure('native_engine', 'decode blew up');
    final toServer = await serveWith((cast) => engine);
    toServer
      ..send(request(1))
      ..send(request(2));
    final collected = await replies.stream.take(2).toList();
    expect(collected[0]['ok'], isFalse);
    expect(collected[0]['code'], 'unavailable');
    expect(collected[0]['retryable'], isTrue);
    expect(collected[1]['ok'], isFalse);
    expect(collected[1]['code'], 'native_engine');
    expect(collected[1]['retryable'], isFalse);
  });

  test('a factory refusal (unknown cast) surfaces as retryable unavailability',
      () async {
    final toServer = await serveWith(
      (cast) => throw BrainUnavailable('unknown_local_cast:$cast'),
    );
    toServer.send(request(1, cast: 'no-such-cast'));
    final reply = await replies.stream.first;
    expect(reply['ok'], isFalse);
    expect(reply['code'], 'unavailable');
    expect(reply['retryable'], isTrue);
    expect(reply['message'], contains('no-such-cast'));
  });

  group('the runtime-LoRA attach law', () {
    test('an attachLora command round-trips the attachment record', () async {
      final engine = _AttachableEngine();
      final toServer = await serveWith((cast) => engine);
      toServer.send(<String, Object?>{
        'id': 11,
        'op': 'attachLora',
        'cast': 'qwen',
        'loraPath': '/loras/mean/adapter.safetensors',
        'loraScale': 0.5,
      });
      final reply = await replies.stream.first;
      expect(reply['id'], 11);
      expect(reply['ok'], isTrue);
      expect(reply['digest'], 'digest-1');
      expect(reply['applied'], 3);
      expect(
        engine.attaches.single,
        (path: '/loras/mean/adapter.safetensors', scale: 0.5),
      );
    });

    test('an unchanged (path, scale) skips the native re-attach', () async {
      final engine = _AttachableEngine();
      final toServer = await serveWith((cast) => engine);
      Map<String, Object?> attach(int id, {double scale = 0.5}) =>
          <String, Object?>{
            'id': id,
            'op': 'attachLora',
            'cast': 'qwen',
            'loraPath': '/loras/mean/adapter.safetensors',
            'loraScale': scale,
          };
      toServer
        ..send(attach(21))
        ..send(attach(22));
      final collected = await replies.stream.take(2).toList();
      expect(collected.map((final r) => r['ok']), everyElement(isTrue));
      // The second attach re-replies the RECORDED digest — the native
      // attach ran exactly once (the Rust side is idempotent anyway; the
      // skip avoids the redundant file-hash round trip).
      expect(engine.attachCalls, 1);
      expect(collected.last['digest'], 'digest-1');
      // A different scale is a different state: it re-attaches.
      toServer.send(attach(23, scale: 2));
      final rescaled = await replies.stream.first;
      expect(rescaled['ok'], isTrue);
      expect(engine.attachCalls, 2);
      expect(rescaled['digest'], 'digest-2');
    });

    test('a generate that names a lora attaches BEFORE it infers', () async {
      final engine = _AttachableEngine();
      final toServer = await serveWith((cast) => engine);
      toServer.send(
        request(
          31,
          loraPath: '/loras/mean/adapter.safetensors',
          loraScale: 0.5,
        ),
      );
      final reply = await replies.stream.first;
      expect(reply['ok'], isTrue);
      expect(reply['text'], 'lora answer');
      // THE LAW: the pairing is explicit — attach, then infer, in that
      // order, serialized by the same queue that dispatched the job.
      expect(engine.order, [
        'attach:/loras/mean/adapter.safetensors@0.5',
        'infer',
      ]);
      // And a second generate with the same (path, scale) rides the
      // already-attached adapter — no re-attach between generates.
      toServer.send(
        request(
          32,
          loraPath: '/loras/mean/adapter.safetensors',
          loraScale: 0.5,
        ),
      );
      await replies.stream.first;
      expect(engine.order, hasLength(3));
      expect(engine.order.last, 'infer');
      expect(engine.attachCalls, 1);
    });

    test('a failed attach refuses the generate — never a bare-base decode',
        () async {
      final engine = _AttachableEngine(attachFails: true);
      final toServer = await serveWith((cast) => engine);
      toServer.send(request(41, loraPath: '/loras/bad/adapter.safetensors'));
      final reply = await replies.stream.first;
      expect(reply['ok'], isFalse);
      expect(reply['code'], 'lora_attach_failed');
      expect(reply['message'], contains('missing module'));
      expect(reply['retryable'], isFalse);
      // The generate never ran.
      expect(engine.inferCalls, 0);
    });

    test('a dylib without the attach ABI answers the named lora_abi_missing',
        () async {
      final engine = _AttachableEngine(attachSupported: false);
      final toServer = await serveWith((cast) => engine);
      toServer.send(request(42, loraPath: '/loras/mean/adapter.safetensors'));
      final reply = await replies.stream.first;
      expect(reply['ok'], isFalse);
      expect(reply['code'], 'lora_abi_missing');
      expect(reply['retryable'], isFalse);
      expect(engine.inferCalls, 0, reason: 'no silent bare-base decode');
    });

    test('an engine without an attach surface answers lora_unsupported_engine',
        () async {
      final plain = _FakeEngine('plain')..enqueueText('bare');
      final toServer = await serveWith((cast) => plain);
      toServer.send(request(43, loraPath: '/loras/mean/adapter.safetensors'));
      final reply = await replies.stream.first;
      expect(reply['ok'], isFalse);
      expect(reply['code'], 'lora_unsupported_engine');
      expect(plain._requests, isEmpty, reason: 'the generate was refused');
    });

    test('an attachLora command on a fresh cast resets the record', () async {
      // A NEW client (isolate respawn / first cast use) always runs the
      // bare base — a fresh server with a fresh engine re-attaches even
      // though the previous server had recorded the same (path, scale).
      final first = _AttachableEngine();
      final firstServer = await serveWith((cast) => first);
      firstServer.send(<String, Object?>{
        'id': 51,
        'op': 'attachLora',
        'cast': 'qwen',
        'loraPath': '/loras/mean/adapter.safetensors',
        'loraScale': 1.0,
      });
      await replies.stream.first;
      expect(first.attachCalls, 1);
    });
  });
}
