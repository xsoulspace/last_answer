import 'package:lastanswer/data_agents/subscriptions/grok_gateway.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

const grokBackend = 'xai_grok_plan';

enum GrokModelName implements ModelName { subscription }

String grokConsentProvider(String subject) => '$grokBackend:$subject';

InferenceClientBinding grokHarnessBinding({
  required GrokGateway gateway,
  required String subject,
  required String model,
  String reasoningEffort = 'low',
}) => InferenceClientBinding(
  modelName: GrokModelName.subscription,
  defaultModel: model,
  generationOptions: GenerationOptions(reasoningEffort: reasoningEffort),
  createClient: (selected) {
    if (selected != model) {
      throw StateError('subscription_model_binding_mismatch');
    }
    final client = gateway.inferenceClient(subject, selected);
    if (client is! CancellableInferenceClient) {
      throw StateError('subscription_cancellation_unavailable');
    }
    return client;
  },
  releaseClient: gateway.releaseClient,
);
