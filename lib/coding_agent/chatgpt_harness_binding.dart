import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

const chatGptBackend = 'openai_chatgpt_plan';

enum ChatGptModelName implements ModelName { subscription }

String chatGptConsentProvider(String clientId) => '$chatGptBackend:$clientId';

InferenceClientBinding chatGptHarnessBinding({
  required ChatGptGateway gateway,
  required String clientId,
  required String model,
}) => InferenceClientBinding(
  modelName: ChatGptModelName.subscription,
  defaultModel: model,
  createClient: (selected) {
    if (selected != model) {
      throw StateError('subscription_model_binding_mismatch');
    }
    final client = gateway.inferenceClient(clientId, selected);
    if (client is! CancellableInferenceClient) {
      throw StateError('subscription_cancellation_unavailable');
    }
    return client;
  },
  releaseClient: gateway.releaseClient,
);
