import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_io.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory;

final class BlockedSecureStore implements SecureValueStore {
  final readStarted = Completer<void>();
  final readGate = Completer<String?>();
  @override
  Future<String?> read(String key) {
    if (!readStarted.isCompleted) readStarted.complete();
    return readGate.future;
  }

  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> delete(String key) async {}
}

void main() {
  test(
    'transport diagnostics remain bounded and detached from callers',
    () async {
      final gateway = NativeChatGptGateway(
        credentials: ChatGptCredentials(secureValues: SecureMemory()),
      );
      final client = gateway.inferenceClient(
        'secret-registration',
        'test-model',
      );
      for (var index = 0; index < 17; index++) {
        // Preflight refuses before any protected-store or remote work.
        final result = await client.infer(
          InferenceRequest.structured(prompt: 'secret-prompt', maxTokens: 1),
        );
        expect(result.error!.code, 'generation_option_unsupported');
      }
      await gateway.releaseClient(client);
      final entries = gateway.transportDecisions;
      expect(entries, hasLength(16));
      expect(entries.every((entry) => entry['operation'] == 'actor'), true);
      expect(entries.last['outcome'], 'generation_option_unsupported');
      expect(jsonEncode(entries), isNot(contains('secret')));
      (entries.last['outputKinds']! as Map)['injected'] = 1;
      entries.last['outcome'] = 'injected';
      expect(
        jsonEncode(gateway.transportDecisions),
        isNot(contains('injected')),
      );
      await gateway.dispose();
    },
  );

  test(
    'cancel before protected-store readiness never opens the browser',
    () async {
      final secure = BlockedSecureStore();
      var opened = false;
      final gateway = NativeChatGptGateway(
        credentials: ChatGptCredentials(secureValues: secure),
        openBrowser: (_) async => opened = true,
      );
      final signIn = gateway.signIn();
      final failure = expectLater(
        signIn,
        throwsA(
          isA<ChatGptAuthException>().having(
            (e) => e.code,
            'code',
            'authorization_cancelled',
          ),
        ),
      );
      await secure.readStarted.future;
      await gateway.cancelAccountOperation();
      secure.readGate.complete(null);
      await failure;
      expect(opened, false);
      await gateway.dispose();
    },
  );

  test(
    'actor clients have independent ownership and disposal is fenced',
    () async {
      final gateway = NativeChatGptGateway(
        credentials: ChatGptCredentials(secureValues: SecureMemory()),
      );
      final first = gateway.inferenceClient('registration', 'model');
      final second = gateway.inferenceClient('registration', 'model');
      expect(identical(first, second), false);
      await gateway.cancelAccountOperation();
      await gateway.releaseClient(first);
      await gateway.releaseClient(first);
      await gateway.dispose();
      expect(gateway.supported, false);
      expect(
        () => gateway.inferenceClient('registration', 'model'),
        throwsA(
          isA<ChatGptAuthException>().having(
            (e) => e.code,
            'code',
            'gateway_disposed',
          ),
        ),
      );
    },
  );
}
