import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';

import 'package:lastanswer/doc/openrouter_doc_inference_port.dart';

/// Readiness of a hosted chat turn, resolved BEFORE any text leaves the
/// device. Never a mid-send surprise: the surface names the fix.
enum HostedChatReadiness { ready, missingCredential, consentRequired }

/// One resolved hosted chat lane.
final class HostedChatResolution {
  const HostedChatResolution._(this.readiness, {this.port});

  const HostedChatResolution.ready(DocInferencePort port)
    : this._(HostedChatReadiness.ready, port: port);
  const HostedChatResolution.missingCredential()
    : this._(HostedChatReadiness.missingCredential);
  const HostedChatResolution.consentRequired()
    : this._(HostedChatReadiness.consentRequired);

  final HostedChatReadiness readiness;
  final DocInferencePort? port;
}

/// Resolves a hosted [DocInferencePort] for a chat document from the
/// agent-platform config + per-provider secure-store keys + per-document
/// cloud consent.
///
/// Key precedence (documented, deterministic): secure-store key entered via
/// the settings pane first, then the environment variable named by the
/// provider config's `apiKeyEnv`. Consent is scoped to
/// (document, provider, model, 'chat') — a copied document asks again.
final class ChatInferenceResolver {
  ChatInferenceResolver({
    required this._configStore,
    required this._providerKeys,
    @visibleForTesting this._portFactory,
  });

  final AgentConfigStore _configStore;
  final ProviderConfigurationStore _providerKeys;
  final DocInferencePort Function(
    String providerId,
    String model,
    String apiKey,
  )? _portFactory;

  static const chatWorkspace = 'chat';

  /// Resolves the hosted lane for [documentId] on [providerId]/[model].
  /// Throws [StateError] for an unknown provider id — configuration errors
  /// are named, never guessed.
  Future<HostedChatResolution> resolve({
    required String documentId,
    required String providerId,
    required String model,
  }) async {
    final provider = _configStore.config.providers[providerId];
    if (provider == null) {
      throw StateError('unknown chat provider: $providerId');
    }
    if (model.isEmpty) {
      throw StateError('no model selected for provider $providerId');
    }
    var key = await _providerKeys.readProviderKey(providerId);
    if (key == null || key.isEmpty) {
      final envName = provider.apiKeyEnv;
      if (envName.isNotEmpty) {
        final value = _configStore.environment[envName];
        if (value != null && value.isNotEmpty) key = value;
      }
    }
    if (key == null || key.isEmpty) {
      return const HostedChatResolution.missingCredential();
    }
    final consent = await _providerKeys.consentGranted(
      documentId: documentId,
      provider: providerId,
      model: model,
      workspace: chatWorkspace,
    );
    if (!consent) return const HostedChatResolution.consentRequired();
    if (providerId == AgentPlatformConfig.openRouterId) {
      final port = _portFactory != null
          ? _portFactory(providerId, model, key)
          : OpenRouterDocInferencePort(
              apiKey: key,
              model: model,
              baseUrl: provider.baseUrl.isEmpty ? null : provider.baseUrl,
            );
      return HostedChatResolution.ready(port);
    }
    throw StateError('no chat transport for provider: $providerId');
  }

  /// Records the user's consent for (document, provider, model, chat).
  Future<void> grantConsent({
    required String documentId,
    required String providerId,
    required String model,
  }) => _providerKeys.grantHostedConsent(
    documentId: documentId,
    provider: providerId,
    model: model,
    workspace: chatWorkspace,
  );

  /// The default hosted target from config (provider id + model), or null
  /// when no default is configured.
  ({String providerId, String model})? defaultTarget() {
    final chat = _configStore.config.chat;
    if (chat.defaultProvider.isEmpty) return null;
    final provider = _configStore.config.providers[chat.defaultProvider];
    if (provider == null) return null;
    var model = chat.defaultModel;
    if (model.isEmpty) {
      model = provider.defaultModel.isNotEmpty
          ? provider.defaultModel
          : (provider.models.isNotEmpty ? provider.models.first : '');
    }
    if (model.isEmpty) return null;
    return (providerId: chat.defaultProvider, model: model);
  }
}
