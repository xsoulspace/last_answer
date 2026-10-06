import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lastanswer/doc/openrouter_doc_inference_port.dart';
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart';

http.Response _completion({
  required String model,
  required String content,
  required int statusCode,
}) => http.Response(
  jsonEncode({
    'id': 'resp-1',
    'model': model,
    'choices': [
      {
        'message': {'role': 'assistant', 'content': content},
        'finish_reason': 'stop',
      },
    ],
  }),
  statusCode,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('renders system prompt, history, and the final user message',
      () async {
    final bodies = <Map<String, dynamic>>[];
    final client = OpenRouterInferenceClient(
      apiKey: 'k',
      defaultModel: 'test/model',
      httpClient: MockClient((request) async {
        bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return _completion(
          model: 'test/model',
          content: 'a reply',
          statusCode: 200,
        );
      }),
    );
    final port = OpenRouterDocInferencePort(
      apiKey: 'k',
      model: 'test/model',
      client: client,
    );

    final deltas = await port
        .chat([
          const ChatMessage(role: 'system', content: 'be terse'),
          const ChatMessage(role: 'user', content: 'first question'),
          const ChatMessage(role: 'assistant', content: 'first answer'),
          const ChatMessage(role: 'user', content: 'second question'),
        ])
        .toList();

    expect(deltas, ['a reply']);
    expect(bodies, hasLength(1));
    final messages =
        (bodies.single['messages'] as List).cast<Map<String, dynamic>>();
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], 'be terse');
    // Prior assistant turns render as native assistant messages (the
    // context-fragment wire contract); prior user text lands in the
    // projected-context message.
    expect(
      messages.any(
        (message) =>
            message['role'] == 'assistant' && message['content'] ==
            'first answer',
      ),
      isTrue,
    );
    expect(messages.last['role'], 'user');
    expect(messages.last['content'], 'second question');
    expect(bodies.single['model'], 'test/model');
  });

  test('surfaces API errors as named failures', () async {
    final client = OpenRouterInferenceClient(
      apiKey: 'bad',
      defaultModel: 'test/model',
      httpClient: MockClient(
        (request) async => _completion(
          model: 'test/model',
          content: 'denied',
          statusCode: 401,
        ),
      ),
    );
    final port = OpenRouterDocInferencePort(
      apiKey: 'bad',
      model: 'test/model',
      client: client,
    );

    await expectLater(
      port.chat([const ChatMessage(role: 'user', content: 'hi')]).drain<void>(),
      throwsA(
        isA<StateError>().having(
          (error) => error.toString(),
          'message',
          contains('auth'),
        ),
      ),
    );
  });

  test('yields nothing for an empty completion', () async {
    final client = OpenRouterInferenceClient(
      apiKey: 'k',
      defaultModel: 'test/model',
      httpClient: MockClient(
        (request) async => _completion(
          model: 'test/model',
          content: '',
          statusCode: 200,
        ),
      ),
    );
    final port = OpenRouterDocInferencePort(
      apiKey: 'k',
      model: 'test/model',
      client: client,
    );
    final deltas = await port
        .chat([const ChatMessage(role: 'user', content: 'hi')])
        .toList();
    expect(deltas, isEmpty);
  });
}
