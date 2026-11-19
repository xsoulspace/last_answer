import 'package:lastanswer/data_agents/subscriptions/chatgpt_gateway_contract.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

/// One application-owned Grok account transport. Tokens stay behind it.
abstract interface class GrokGateway {
  bool get supported;
  bool get registered;
  LastAnswerGrokRegistration get registration;
  Future<String> signIn({String? subject});
  Future<String> signInWithDevice({
    required void Function(GrokDevicePrompt prompt) onPrompt,
    String? subject,
  });
  Future<void> cancelSignIn();
  Future<void> cancelAccountOperation();
  Future<bool> signOut(String subject);
  Future<List<SubscriptionModel>> models(String subject);
  Future<SubscriptionAccessReceipt> verifyAccess(String subject, String model);
  InferenceClient inferenceClient(String subject, String model);
  Future<void> releaseClient(InferenceClient client);
  Future<void> dispose();
}
