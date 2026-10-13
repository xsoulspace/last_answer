import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_harness_binding.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_openai/xsoulspace_inference_openai.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory, record;

void main() {
  test(
    'native Responses calls run through host permission and verification',
    () async {
      final workspace = await Directory.systemTemp.createTemp(
        'native_subscription_host',
      );
      addTearDown(() => workspace.delete(recursive: true));
      final source = File('${workspace.path}/main.dart');
      await source.writeAsString(
        "void main() { throw StateError('unfixed'); }\n",
      );
      final store = ChatGptCredentials(secureValues: SecureMemory());
      final hostId = await store.ensureHostId();
      await store.write(record(hostId, 'fixture-client'));
      final auth = ChatGptAuth(store: store);
      addTearDown(auth.close);
      final requests = <Map<String, dynamic>>[];
      final transport = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        requests.add(body);
        expect(body['store'], false);
        expect(body['stream'], true);
        expect(body.containsKey('previous_response_id'), false);
        expect(body['input'], isNotEmpty);
        final output = requests.length == 1
            ? [
                {
                  'type': 'function_call',
                  'name': 'write',
                  'namespace': 'harness',
                  'call_id': 'fixture-call',
                  'arguments': jsonEncode({
                    'path': 'main.dart',
                    'content': "void main() { print('ok'); }\n",
                  }),
                },
              ]
            : [
                {
                  'type': 'message',
                  'role': 'assistant',
                  'content': [
                    {'type': 'output_text', 'text': 'done'},
                  ],
                },
              ];
        return http.Response(
          'data: ${jsonEncode({
            'type': 'response.completed',
            'response': {
              'id': 'fixture-response-${requests.length}',
              'status': 'completed',
              'output': output,
              'usage': {'input_tokens': 100, 'output_tokens': 20},
            },
          })}\n\n',
          200,
        );
      });
      addTearDown(transport.close);
      final binding = InferenceClientBinding(
        modelName: ChatGptModelName.subscription,
        defaultModel: 'fixture-model',
        createClient: (model) => OpenAiResponsesClient(
          auth: auth,
          clientId: 'fixture-client',
          model: model,
          client: transport,
        ),
      );
      addTearDown(binding.dispose);
      final host = HarnessHost(
        config: HarnessHostConfig(
          backend: chatGptBackend,
          model: 'fixture-model',
          inferenceBinding: binding,
        ),
      );
      addTearDown(host.stop);
      await host.start();
      final session = await host.newSession(workspace.path);
      var permissions = 0;
      host.permissionRequests.listen((pending) {
        permissions++;
        pending.allow();
      });
      final visible = StringBuffer();
      await host.delegateTask(
        session,
        'Fix main.dart so dart run main.dart exits 0.',
        onText: visible.write,
      );
      expect(requests, isNotEmpty);
      expect(permissions, greaterThan(0));
      expect(await source.readAsString(), contains("print('ok')"));
      expect(visible.toString(), contains('verdict: PASS'));
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
