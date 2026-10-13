import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show ProviderUsage;
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';

/// Device-local state holder. Account consent never implies document consent.
final class ChatGptSubscriptionController extends ChangeNotifier {
  ChatGptSubscriptionController({
    required this.credentials,
    ChatGptGateway? gateway,
  }) : gateway = gateway ?? createChatGptGateway(credentials);

  final ChatGptCredentials credentials;
  final ChatGptGateway gateway;
  List<ChatGptProfile> profiles = const [];
  List<SubscriptionModel> models = const [];
  String? activeClientId;
  SubscriptionAccessReceipt? accessReceipt;
  String? errorCode;
  bool initialized = false;
  bool busy = false;
  bool signingIn = false;
  bool? revocationConfirmed;
  bool persistedCleanupUnconfirmed = false;
  bool get hasUnconfirmedCleanup =>
      persistedCleanupUnconfirmed || gateway.hasUnconfirmedCleanup;
  bool _disposed = false;
  Future<void>? _loading;
  bool get supported => gateway.supported;
  ChatGptProfile? get activeProfile {
    for (final profile in profiles) {
      if (profile.clientId == activeClientId) return profile;
    }
    return null;
  }

  String? get selectedModel => activeProfile?.model;

  Map<String, Object?> snapshot() => {
    'supported': supported,
    'initialized': initialized,
    'busy': busy,
    'signingIn': signingIn,
    'activeClientId': activeClientId,
    'selectedModel': selectedModel,
    'error': errorCode,
    'remoteRevocationConfirmed': revocationConfirmed,
    'unconfirmedAuthorizationCleanup': hasUnconfirmedCleanup,
    'profiles': [
      for (final profile in profiles)
        {
          'clientId': profile.clientId,
          'email': profile.email,
          'signedIn': profile.signedIn,
          'planEnabled': profile.planEnabled,
          'recoveryRequired': profile.recoveryRequired,
          'cleanupUnconfirmed': profile.cleanupUnconfirmed,
          'model': profile.model,
        },
    ],
    'models': [
      for (final model in models)
        {'slug': model.slug, 'displayName': model.displayName},
    ],
    if (gateway case final ChatGptTransportDiagnostics diagnostics)
      'transportDecisions': diagnostics.transportDecisions,
    'accessVerified': accessReceipt != null,
    if (accessReceipt != null) 'accessModel': accessReceipt!.model,
    if (accessReceipt != null) 'accessResponseId': accessReceipt!.responseId,
    if (accessReceipt != null)
      'accessUsage': ProviderUsage.fromMeta(accessReceipt!.usage)?.toJson(),
  };

  Future<void> load() {
    if (initialized) return Future.value();
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    await _run(() async {
      if (supported) await _reload();
      initialized = true;
    });
  }

  Future<void> _reload() async {
    profiles = await credentials.profiles();
    activeClientId = await credentials.activeClientId();
    persistedCleanupUnconfirmed = await credentials.hasUnconfirmedCleanup();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy || _disposed) return;
    busy = true;
    errorCode = null;
    _notify();
    try {
      await action();
    } on ChatGptAuthException catch (error) {
      errorCode = error.code;
    } on Object {
      errorCode = 'subscription_operation_failed';
    } finally {
      if (errorCode != null && supported) {
        try {
          await _reload();
          if (activeProfile?.signedIn != true) {
            accessReceipt = null;
            models = const [];
          }
        } on Object {
          // A stale local projection cannot stand in for unreadable authority.
          profiles = const [];
          activeClientId = null;
          models = const [];
          accessReceipt = null;
          initialized = false;
        }
      }
      busy = false;
      signingIn = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> signIn({String? clientId}) => _run(() async {
    accessReceipt = null;
    models = const [];
    signingIn = true;
    _notify();
    final issued = await gateway.signIn(clientId: clientId);
    await credentials.selectAccount(issued);
    await _reload();
    accessReceipt = null;
    revocationConfirmed = null;
    await _refreshModels();
  });
  Future<void> cancelSignIn() => gateway.cancelSignIn();
  Future<void> cancel() => gateway.cancelAccountOperation();

  Future<void> selectAccount(String clientId) => _run(() async {
    await credentials.selectAccount(clientId);
    await _reload();
    models = const [];
    accessReceipt = null;
    await _refreshModels();
  });
  Future<void> refreshModels() => _run(_refreshModels);
  Future<void> _refreshModels() async {
    models = const [];
    accessReceipt = null;
    final profile = activeProfile;
    if (profile == null || !profile.signedIn || !profile.planEnabled) return;
    models = List.unmodifiable(await gateway.models(profile.clientId));
    // Preserve account-specific choices. A removed catalog model requires a
    // visible new selection rather than silently dispatching a different model.
  }

  Future<void> selectModel(String model) => _run(() async {
    final clientId = activeClientId;
    if (clientId == null || !models.any((entry) => entry.slug == model)) {
      throw const ChatGptAuthException('model_not_available');
    }
    await credentials.selectModel(clientId, model);
    await _reload();
    accessReceipt = null;
  });
  Future<void> verifyAccess() => _run(() async {
    accessReceipt = null;
    final clientId = activeClientId;
    final model = selectedModel;
    if (clientId == null ||
        model == null ||
        !models.any((entry) => entry.slug == model)) {
      throw const ChatGptAuthException('model_required');
    }
    accessReceipt = await gateway.verifyAccess(clientId, model);
  });
  Future<void> signOut() => _run(() async {
    final clientId = activeClientId;
    if (clientId == null) return;
    accessReceipt = null;
    models = const [];
    revocationConfirmed = await gateway.signOut(clientId);
    await _reload();
  });

  @override
  void dispose() {
    _disposed = true;
    unawaited(gateway.dispose());
    super.dispose();
  }
}
