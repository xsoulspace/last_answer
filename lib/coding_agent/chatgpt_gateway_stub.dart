import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

ChatGptGateway createChatGptGateway(ChatGptCredentials credentials) =>
    UnsupportedChatGptGateway();

final class UnsupportedChatGptGateway implements ChatGptGateway {
  @override
  bool get supported => false;
  @override
  bool get hasUnconfirmedCleanup => false;
  Never _unavailable() =>
      throw const ChatGptAuthException('platform_unsupported');
  @override
  Future<String> signIn({String? clientId}) async => _unavailable();
  @override
  Future<void> cancelSignIn() async {}
  @override
  Future<void> cancelAccountOperation() async {}
  @override
  Future<bool> signOut(String clientId) async => _unavailable();
  @override
  Future<List<SubscriptionModel>> models(String clientId) async =>
      _unavailable();
  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String clientId,
    String model,
  ) async => _unavailable();
  @override
  InferenceClient inferenceClient(String clientId, String model) =>
      _unavailable();
  @override
  Future<void> releaseClient(InferenceClient client) async {}
  @override
  Future<void> dispose() async {}
}
