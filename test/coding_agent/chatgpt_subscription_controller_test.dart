import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory, record;

final class FakeChatGptGateway implements ChatGptGateway {
  FakeChatGptGateway(this.store);
  final ChatGptCredentials store;
  Completer<void>? signInGate;
  Future<void> Function()? beforeSignIn;
  bool planEnabled = true;
  int probes = 0;
  int catalogCalls = 0;
  bool remoteRevoked = true;
  String? returningClientId;
  @override
  bool get supported => true;
  @override
  bool get hasUnconfirmedCleanup => false;
  @override
  Future<String> signIn({String? clientId}) async {
    if (beforeSignIn case final hook?) await hook();
    returningClientId = clientId;
    if (signInGate != null) await signInGate!.future;
    final hostId = await store.ensureHostId();
    final id = clientId ?? 'fixture-client';
    final original = record(hostId, id);
    await store.write(
      ChatGptAccount(
        clientId: id,
        hostId: hostId,
        subject: original.subject,
        email: original.email,
        accessToken: original.accessToken,
        refreshToken: original.refreshToken,
        idToken: original.idToken,
        expiresAt: original.expiresAt,
        scopes: planEnabled ? original.scopes : {'openid'},
      ),
    );
    return id;
  }

  @override
  Future<void> cancelSignIn() async {
    signInGate?.completeError(
      const ChatGptAuthException('authorization_cancelled'),
    );
    signInGate = null;
  }

  @override
  Future<void> cancelAccountOperation() => cancelSignIn();

  @override
  Future<bool> signOut(String clientId) async {
    final mutation = await store.beginMutation(clientId);
    await store.removeTokens(clientId);
    final confirmed =
        remoteRevoked &&
        !mutation.wasUnsettled &&
        !mutation.hasUnconfirmedCleanup;
    await store.finishMutation(clientId, cleanupConfirmed: confirmed);
    return confirmed;
  }

  @override
  Future<List<SubscriptionModel>> models(String clientId) async {
    catalogCalls++;
    return const [
      SubscriptionModel(slug: 'fixture-model', displayName: 'Fixture model'),
    ];
  }

  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String clientId,
    String model,
  ) async {
    probes++;
    return SubscriptionAccessReceipt(
      model: model,
      responseId: 'fixture-response',
      usage: const {'input_tokens': 20},
    );
  }

  @override
  InferenceClient inferenceClient(String clientId, String model) =>
      throw UnimplementedError('Not used by account controls');
  @override
  Future<void> releaseClient(InferenceClient client) async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  test('failed authorization reloads fenced authority instead of '
      'retaining signed-in state', () async {
    final store = ChatGptCredentials(secureValues: SecureMemory());
    final gateway = FakeChatGptGateway(store);
    await gateway.signIn();
    await store.selectAccount('fixture-client');
    final state = ChatGptSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    expect(state.activeProfile!.signedIn, true);
    gateway.beforeSignIn = () async {
      await store.beginMutation('fixture-client');
      throw const ChatGptAuthException('credential_publication_unsettled');
    };
    await state.signIn(clientId: 'fixture-client');
    expect(state.activeProfile!.signedIn, false);
    expect(state.activeProfile!.recoveryRequired, true);
    expect(state.errorCode, 'credential_publication_unsettled');
    expect(state.snapshot()['accessVerified'], false);
  });

  test(
    'account identity, catalog and completed access evidence are distinct',
    () async {
      final store = ChatGptCredentials(secureValues: SecureMemory());
      final gateway = FakeChatGptGateway(store);
      final state = ChatGptSubscriptionController(
        credentials: store,
        gateway: gateway,
      );
      addTearDown(state.dispose);
      await state.load();
      await state.signIn();
      expect(state.activeClientId, 'fixture-client');
      expect(state.accessReceipt, isNull);
      expect(state.selectedModel, isNull);
      expect(gateway.probes, 0);
      await state.selectModel('fixture-model');
      await state.verifyAccess();
      expect(state.accessReceipt!.responseId, 'fixture-response');
      expect(gateway.probes, 1);
      final safe = state.snapshot().toString();
      expect(safe, isNot(contains('fixture-access')));
      expect(safe, isNot(contains('fixture-refresh')));
      await state.selectModel('unavailable');
      expect(state.errorCode, 'model_not_available');
    },
  );

  test('identity-only consent does not list models or expose access', () async {
    final store = ChatGptCredentials(secureValues: SecureMemory());
    final gateway = FakeChatGptGateway(store)..planEnabled = false;
    final state = ChatGptSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    await state.signIn();
    expect(state.activeProfile!.planEnabled, false);
    expect(gateway.catalogCalls, 0);
    await state.verifyAccess();
    expect(gateway.probes, 0);
  });

  test(
    'browser cancellation restores idle state without account publication',
    () async {
      final store = ChatGptCredentials(secureValues: SecureMemory());
      final gateway = FakeChatGptGateway(store)..signInGate = Completer<void>();
      final state = ChatGptSubscriptionController(
        credentials: store,
        gateway: gateway,
      );
      addTearDown(state.dispose);
      final signing = state.signIn();
      expect(state.signingIn, true);
      await state.cancelSignIn();
      await signing;
      expect(state.busy, false);
      expect(state.errorCode, 'authorization_cancelled');
      expect(await store.profiles(), isEmpty);
    },
  );

  test(
    'signed-out registration retains client identity without an ID hint',
    () async {
      final store = ChatGptCredentials(secureValues: SecureMemory());
      final gateway = FakeChatGptGateway(store)..remoteRevoked = false;
      final state = ChatGptSubscriptionController(
        credentials: store,
        gateway: gateway,
      );
      addTearDown(state.dispose);
      await state.signIn();
      await state.signOut();
      expect(state.revocationConfirmed, false);
      expect(state.activeClientId, isNull);
      final registration = await store.registration('fixture-client');
      expect(registration!.idTokenHint, isNull);
      await state.signIn(clientId: registration.clientId);
      expect(gateway.returningClientId, registration.clientId);
    },
  );
}
