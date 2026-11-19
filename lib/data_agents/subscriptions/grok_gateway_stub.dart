import 'package:lastanswer/data_agents/subscriptions/chatgpt_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_credentials.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway_contract.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

GrokGateway createGrokGateway(GrokCredentials credentials) =>
    UnsupportedGrokGateway();

final class UnsupportedGrokGateway implements GrokGateway {
  @override
  bool get supported => false;
  @override
  bool get registered => false;
  @override
  LastAnswerGrokRegistration get registration =>
      const LastAnswerGrokRegistration(clientId: '');
  Never _unavailable() => throw const GrokAuthException('platform_unsupported');
  @override
  Future<String> signIn({String? subject}) async => _unavailable();
  @override
  Future<String> signInWithDevice({
    required void Function(GrokDevicePrompt prompt) onPrompt,
    String? subject,
  }) async => _unavailable();
  @override
  Future<void> cancelSignIn() async {}
  @override
  Future<void> cancelAccountOperation() async {}
  @override
  Future<bool> signOut(String subject) async => _unavailable();
  @override
  Future<List<SubscriptionModel>> models(String subject) async =>
      _unavailable();
  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String subject,
    String model,
  ) async => _unavailable();
  @override
  InferenceClient inferenceClient(String subject, String model) =>
      _unavailable();
  @override
  Future<void> releaseClient(InferenceClient client) async {}
  @override
  Future<void> dispose() async {}
}
