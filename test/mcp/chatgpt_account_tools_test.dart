import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/mcp/chatgpt_mcp_tools.dart';

import '../coding_agent/chatgpt_credentials_test.dart' show SecureMemory;
import '../coding_agent/chatgpt_subscription_controller_test.dart'
    show FakeChatGptGateway;

void main() {
  test(
    'account intents use the product owner and expose no credentials',
    () async {
      final credentials = ChatGptCredentials(secureValues: SecureMemory());
      final gateway = FakeChatGptGateway(credentials);
      final state = ChatGptSubscriptionController(
        credentials: credentials,
        gateway: gateway,
      );
      addTearDown(state.dispose);
      final entries = chatGptMcpEntries(controller: () => state);
      final read = entries.singleWhere(
        (entry) => entry.name == 'chatgpt_account_state',
      );
      final action = entries.singleWhere(
        (entry) => entry.name == 'chatgpt_account_action',
      );
      expect((await read.invokeDirect(const {})).data['initialized'], true);
      expect(
        (await action.invokeDirect(const {'op': 'sign_in'})).data['ok'],
        true,
      );
      expect(
        (await action.invokeDirect(const {
          'op': 'select_model',
          'model': 'fixture-model',
        })).data['selectedModel'],
        'fixture-model',
      );
      final verified = await action.invokeDirect(const {'op': 'verify_access'});
      expect(verified.data['accessVerified'], true);
      expect(gateway.probes, 1);
      final exposed = jsonEncode(verified.data);
      for (final secret in [
        'fixture-access',
        'fixture-refresh',
        'fixture-id',
      ]) {
        expect(exposed, isNot(contains(secret)));
      }
      final signedOut = await action.invokeDirect(const {'op': 'sign_out'});
      expect(signedOut.data['accessVerified'], false);
    expect(state.profiles.single.signedIn, false);
      expect(
        (await action.invokeDirect(const {
          'op': 'select_account',
          'clientId': 'missing',
        })).data['error'],
        'registration_missing',
      );
    },
  );
}
