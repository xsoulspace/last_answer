import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_agents/subscriptions/chatgpt_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_credentials.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_subscription_controller.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory;

final class FakeGrokGateway implements GrokGateway {
  FakeGrokGateway(this.store);
  final GrokCredentials store;
  bool isRegistered = true;
  bool planEnabled = true;
  bool remoteRevoked = true;
  int probes = 0;
  int catalogCalls = 0;
  Completer<void>? signInGate;
  Completer<void>? deviceGate;

  @override
  bool get supported => true;
  @override
  bool get registered => isRegistered;
  @override
  LastAnswerGrokRegistration get registration =>
      LastAnswerGrokRegistration(clientId: isRegistered ? 'la-test' : '');

  Future<String> _publish(String? subject) async {
    final id = subject ?? 'fixture-subject';
    await store.write(
      GrokAccount(
        clientId: 'la-test',
        subject: id,
        email: 'same@example.test',
        accessToken: 'fixture-access',
        refreshToken: 'fixture-refresh',
        idToken: 'fixture-id',
        expiresAt: DateTime.utc(2099),
        scopes: planEnabled ? const {'openid', 'api:access'} : const {'openid'},
      ),
    );
    return id;
  }

  @override
  Future<String> signIn({String? subject}) async {
    if (!isRegistered) throw const GrokAuthException('client_not_registered');
    if (signInGate != null) await signInGate!.future;
    return _publish(subject);
  }

  @override
  Future<String> signInWithDevice({
    required void Function(GrokDevicePrompt prompt) onPrompt,
    String? subject,
  }) async {
    if (!isRegistered) throw const GrokAuthException('client_not_registered');
    onPrompt(
      GrokDevicePrompt(
        userCode: 'ABCD-EFGH',
        verificationUri: Uri.parse('https://auth.x.ai/device'),
      ),
    );
    if (deviceGate != null) await deviceGate!.future;
    return _publish(subject);
  }

  void _cancel(Completer<void>? gate) {
    if (gate != null && !gate.isCompleted) {
      gate.completeError(const GrokAuthException('authorization_cancelled'));
    }
  }

  @override
  Future<void> cancelSignIn() async {
    _cancel(signInGate);
    _cancel(deviceGate);
    signInGate = null;
    deviceGate = null;
  }

  @override
  Future<void> cancelAccountOperation() => cancelSignIn();

  @override
  Future<bool> signOut(String subject) async {
    await store.removeTokens(subject);
    return remoteRevoked;
  }

  @override
  Future<List<SubscriptionModel>> models(String subject) async {
    catalogCalls++;
    return const [
      SubscriptionModel(slug: 'fixture-model', displayName: 'Fixture model'),
    ];
  }

  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String subject,
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
  InferenceClient inferenceClient(String subject, String model) =>
      throw UnimplementedError('Not used by account controls');
  @override
  Future<void> releaseClient(InferenceClient client) async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  test('sign-in stays closed until a client id exists', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..isRegistered = false;
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    await state.signIn();
    expect(state.errorCode, 'client_not_registered');
    expect(state.snapshot()['registered'], false);
    expect(state.snapshot()['referrer'], 'last-answer');
    expect(await store.profiles(), isEmpty);
    expect(gateway.catalogCalls, 0);
  });

  test('account identity, catalog and access evidence stay distinct', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store);
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    await state.signIn();
    expect(state.activeAccountId, 'fixture-subject');
    expect(state.accessReceipt, isNull);
    expect(state.selectedModel, isNull);
    expect(gateway.probes, 0);
    expect(gateway.catalogCalls, 1);
    await state.selectModel('fixture-model');
    await state.verifyAccess();
    expect(state.accessReceipt!.responseId, 'fixture-response');
    expect(gateway.probes, 1);
    final safe = state.snapshot().toString();
    expect(safe, isNot(contains('fixture-access')));
    expect(safe, isNot(contains('fixture-refresh')));
    expect(safe, isNot(contains('fixture-id')));
    await state.selectModel('unavailable');
    expect(state.errorCode, 'model_not_available');
  });

  test('identity-only consent does not list models', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..planEnabled = false;
    final state = GrokSubscriptionController(
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
    expect(state.errorCode, 'model_required');
  });

  test('device code is shown during polling and then cleared', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..deviceGate = Completer<void>();
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    final pending = state.signInWithDevice();
    await Future<void>.delayed(Duration.zero);
    expect(state.devicePrompt!.userCode, 'ABCD-EFGH');
    expect(state.snapshot().toString(), isNot(contains('device-secret')));
    gateway.deviceGate!.complete();
    await pending;
    expect(state.devicePrompt, isNull);
    expect(state.activeAccountId, 'fixture-subject');
    expect(await store.read('fixture-subject'), isNotNull);
  });

  test('cancellation publishes no account', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..signInGate = Completer<void>();
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    final signing = state.signIn();
    expect(state.busy, true);
    await state.cancel();
    await signing;
    expect(state.busy, false);
    expect(state.errorCode, 'authorization_cancelled');
    expect(await store.profiles(), isEmpty);
  });

  test('sign-out removes tokens and keeps the email', () async {
    final store = GrokCredentials(secureValues: SecureMemory());
    final gateway = FakeGrokGateway(store)..remoteRevoked = false;
    final state = GrokSubscriptionController(
      credentials: store,
      gateway: gateway,
    );
    addTearDown(state.dispose);
    await state.load();
    await state.signIn();
    await state.signOut();
    expect(state.revocationConfirmed, false);
    expect(state.activeAccountId, isNull);
    expect(await store.read('fixture-subject'), isNull);
    expect(state.profiles.single.email, 'same@example.test');
    expect(state.profiles.single.signedIn, false);
  });
}
