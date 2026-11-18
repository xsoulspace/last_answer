import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/grok_gateway_contract.dart';
import 'package:lastanswer/coding_agent/grok_harness_binding.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

void main() {
  test('the harness binding keeps the selected model and cancellation', () {
    final gateway = _BindingGateway();
    final binding = grokHarnessBinding(
      gateway: gateway,
      subject: 'user-1',
      model: 'grok-test',
    );
    expect(grokConsentProvider('user-1'), 'xai_grok_plan:user-1');
    expect(
      binding.createClient('grok-test'),
      isA<CancellableInferenceClient>(),
    );
    expect(
      () => binding.createClient('other'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'subscription_model_binding_mismatch',
        ),
      ),
    );
    gateway.cancellable = false;
    expect(
      () => binding.createClient('grok-test'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'subscription_cancellation_unavailable',
        ),
      ),
    );
  });
}

final class _BindingGateway implements GrokGateway {
  bool cancellable = true;
  @override
  bool get supported => true;
  @override
  bool get registered => true;
  @override
  LastAnswerGrokRegistration get registration =>
      const LastAnswerGrokRegistration(clientId: 'la-test');
  @override
  InferenceClient inferenceClient(String subject, String model) =>
      cancellable ? _CancellableClient() : _PlainClient();
  @override
  Future<void> releaseClient(InferenceClient client) async {}
  @override
  Future<String> signIn({String? subject}) => throw UnimplementedError();
  @override
  Future<String> signInWithDevice({
    required void Function(GrokDevicePrompt prompt) onPrompt,
    String? subject,
  }) => throw UnimplementedError();
  @override
  Future<void> cancelSignIn() async {}
  @override
  Future<void> cancelAccountOperation() async {}
  @override
  Future<bool> signOut(String subject) => throw UnimplementedError();
  @override
  Future<List<SubscriptionModel>> models(String subject) =>
      throw UnimplementedError();
  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String subject,
    String model,
  ) => throw UnimplementedError();
  @override
  Future<void> dispose() async {}
}

final class _PlainClient implements InferenceClient {
  @override
  String get id => 'plain';
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const {InferenceTask.text};
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
  }) => throw UnimplementedError();
}

final class _CancellableClient extends _PlainClient
    implements CancellableInferenceClient {
  @override
  void cancelActive() {}
  @override
  Future<void> settleActive() async {}
  @override
  void close() {}
}
