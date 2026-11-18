import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/grok_credentials.dart';
import 'package:lastanswer/coding_agent/grok_subscription_controller.dart';
import 'package:lastanswer/mcp/grok_mcp_tools.dart';

import '../coding_agent/chatgpt_credentials_test.dart' show SecureMemory;
import '../coding_agent/grok_subscription_controller_test.dart'
    show FakeGrokGateway;

void main() {
  test('account intents expose no credentials', () async {
    final credentials = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(credentials);
    final state = GrokSubscriptionController(
      credentials: credentials,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    final entries = grokMcpEntries(controller: () => state);
    final read = entries.singleWhere(
      (entry) => entry.name == 'grok_account_state',
    );
    final action = entries.singleWhere(
      (entry) => entry.name == 'grok_account_action',
    );
    expect((await read.invokeDirect(const {})).data['registered'], true);
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
    for (final secret in ['fixture-access', 'fixture-refresh', 'fixture-id']) {
      expect(exposed, isNot(contains(secret)));
    }
    final signedOut = await action.invokeDirect(const {'op': 'sign_out'});
    expect(signedOut.data['accessVerified'], false);
    expect(state.profiles.single.signedIn, false);
  });

  test('an unregistered client refuses sign-in through the tool', () async {
    final credentials = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(credentials)..isRegistered = false;
    final state = GrokSubscriptionController(
      credentials: credentials,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    final action = grokMcpEntries(
      controller: () => state,
    ).singleWhere((entry) => entry.name == 'grok_account_action');
    final refused = await action.invokeDirect(const {'op': 'sign_in'});
    expect(refused.data['ok'], false);
    expect(refused.data['error'], 'client_not_registered');
    expect(jsonEncode(refused.data), isNot(contains('fixture-access')));
  });
}
