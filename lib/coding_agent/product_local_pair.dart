import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lastanswer/coding_agent/product_cloud_resource.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_laya/xsoulspace_inference_laya.dart';
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart';

/// Device-owned, opt-in resource composition. Existing subscription consent,
/// native source authority and the ordinary task pump remain the owners.
final class ProductLocalPair {
  ProductLocalPair({
    required this.snapshotDir,
    this.maxLocalCalls = 6,
    this.resource = 'qwen',
    this.routeWithLaya = true,
  }) {
    qwen = qwenTextBinding(
      snapshotDir: snapshotDir,
      onEvent: (event) => events.add({
        'at': DateTime.now().toUtc().toIso8601String(),
        ...event,
      }),
      generationOptions: const GenerationOptions(
        maxTokens: 1536,
        thinking: false,
      ),
    );
    final lane = resolveLayaLaneConfig(Platform.environment);
    runtime = LayaServeRuntime(
      healthEndpoint: lane.healthEndpoint,
      spawnOnMiss: lane.mode == LayaLaneMode.lazyShared,
      healthTimeout: const Duration(minutes: 2),
      processStarter: inProcessLayaServeStarter(
        healthEndpoint: lane.healthEndpoint,
      ),
    );
    laya = layaDecisionBinding(
      runtime: runtime,
      endpoint: lane.decisionEndpoint,
      maxSharedCalls: 48,
    );
  }
  static final cloudBudget = ProductCloudBudget(
    File(
      '${Platform.environment['HOME']}/Library/Application Support/dev.xsoulspace.lastAnswer/product_cloud_comparison_budget.json',
    ),
  );
  static Future<Map<String, Object?>> preflightCloud() async {
    final key = Platform.environment['OPENROUTER_API_KEY'];
    if (key == null || key.isEmpty) {
      return {'ok': false, 'error': 'openrouter_key_unavailable'};
    }
    try {
      final response = await http
          .get(
            Uri.parse('https://openrouter.ai/api/v1/auth/key'),
            headers: {'Authorization': 'Bearer $key'},
          )
          .timeout(const Duration(seconds: 10));
      final data = (jsonDecode(response.body) as Map)['data'] as Map;
      final remaining = data['limit_remaining'];
      if (response.statusCode != 200 ||
          remaining is! num ||
          remaining <= 0 ||
          cloudBudget.unknown) {
        return {'ok': false, 'error': 'cloud_budget_preflight_failed'};
      }
      if (remaining < cloudBudget.limit) {
        cloudBudget.limit = remaining.toDouble();
      }
      return {
        'ok': true,
        'providerRemainingUsd': remaining,
        'trial': cloudBudget.summary,
      };
    } on Object {
      return {'ok': false, 'error': 'cloud_budget_preflight_unavailable'};
    }
  }

  final String resource;
  final bool routeWithLaya;
  late final cloud = InferenceClientBinding(
    modelName: OpenRouterModelNames.openRouter,
    defaultModel: ProductCloudClient.model,
    generationOptions: const GenerationOptions(maxTokens: 4096, temperature: 0),
    createClient: (_) => ProductCloudClient(
      apiKey: Platform.environment['OPENROUTER_API_KEY'] ?? '',
      budget: cloudBudget,
    ),
  );
  final String snapshotDir;
  final int maxLocalCalls;
  late final NativeTextClientBinding qwen;
  late final JevClientBinding laya;
  late final LayaServeRuntime runtime;
  final events = <Map<String, Object?>>[];
  final _bindings = Expando<HarnessBackendBinding>();

  HarnessBackendBinding forEscalation(HarnessBackendBinding escalation) =>
      _bindings[escalation] ??= resource == 'luna'
      ? escalation
      : !routeWithLaya
      ? (resource == 'deepseek' ? cloud.binding : qwen.binding)
      : DecisionRoutedGenerationBinding(
          local: resource == 'deepseek' ? cloud.binding : qwen.binding,
          escalation: escalation,
          decide: laya.decideOnce,
          cancelDecision: laya.provider.cancel,
          maxLocalCalls: maxLocalCalls,
          escalateOnAbstention: true,
          onEvent: (event) => events.add({
            'at': DateTime.now().toUtc().toIso8601String(),
            ...event,
          }),
        ).binding;

  Map<String, Object?> toJson() => {
    'resource': resource,
    'routeWithLaya': routeWithLaya,
    if (resource == 'deepseek') 'cloudBudget': cloudBudget.summary,
    if (resource == 'deepseek') 'cloudBilling': cloudBudget.events,
    'qwenSnapshot': snapshotDir,
    'localQuarantined': qwen.isQuarantined,
    'thinking': false,
    'outputTokens': resource == 'qwen'
        ? 1536
        : resource == 'deepseek'
        ? 4096
        : null,
    'inferenceDeadlineMs': 30000,
    'loadDeadlineMs': 120000,
    'settlementDeadlineMs': 5000,
    'maxLocalCallsPerActor': maxLocalCalls,
    'selectorCalls': laya.providerCalls,
    'selectorReadiness': laya.provider.readiness.reasonCode,
    'layaRuntime': {
      'state': runtime.status.$1.name,
      'detail': runtime.status.$2,
    },
    'localFailureCeiling': 2,
    'abstentionPolicy': 'explicitly_authorized_luna_escalation',
    'events': events,
  };
}
