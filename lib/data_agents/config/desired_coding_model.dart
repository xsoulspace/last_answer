import 'package:lastanswer/data_agents/subscriptions/chatgpt_harness_binding.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_harness_binding.dart';

/// One model choice for configuration, document consent and dispatch.
/// Retains the existing transition defaults; native selection is account-owned.
String? desiredCodingModel({
  required String backend,
  required String currentBackend,
  required String currentModel,
  String? subscriptionModel,
}) {
  if (backend == chatGptBackend || backend == grokBackend) {
    return subscriptionModel;
  }
  if (backend == currentBackend) return currentModel;
  return switch (backend) {
    'jev' => 'jev-1.13',
    'laya' => 'laya',
    _ => 'deepseek/deepseek-v4-flash-0731',
  };
}
