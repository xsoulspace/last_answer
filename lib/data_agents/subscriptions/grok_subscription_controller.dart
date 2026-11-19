import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/data_agents/subscriptions/chatgpt_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_credentials.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

/// Device-local Grok plan state. Account consent is not document consent.
final class GrokSubscriptionController extends ChangeNotifier {
  GrokSubscriptionController({required this.credentials, GrokGateway? gateway})
    : gateway = gateway ?? createGrokGateway(credentials);

  final GrokCredentials credentials;
  final GrokGateway gateway;
  List<GrokProfile> profiles = const [];
  List<SubscriptionModel> models = const [];
  String? activeAccountId;
  SubscriptionAccessReceipt? accessReceipt;
  GrokDevicePrompt? devicePrompt;
  String? errorCode;
  bool initialized = false;
  bool busy = false;
  bool? revocationConfirmed;
  bool _disposed = false;
  Future<void>? _loading;

  bool get supported => gateway.supported;
  bool get registered => gateway.registered;
  LastAnswerGrokRegistration get registration => gateway.registration;

  GrokProfile? get activeProfile {
    for (final profile in profiles) {
      if (profile.subject == activeAccountId) return profile;
    }
    return null;
  }

  String? get selectedModel => activeProfile?.model;

  Map<String, Object?> snapshot() => {
    'supported': supported,
    'registered': registered,
    'referrer': LastAnswerGrokRegistration.referrer,
    'redirectUri': LastAnswerGrokRegistration.redirectUri,
    'initialized': initialized,
    'busy': busy,
    'activeAccountId': activeAccountId,
    'selectedModel': selectedModel,
    'error': errorCode,
    'remoteRevocationConfirmed': revocationConfirmed,
    'deviceUserCode': devicePrompt?.userCode,
    'profiles': [
      for (final profile in profiles)
        {
          'subject': profile.subject,
          'email': profile.email,
          'signedIn': profile.signedIn,
          'planEnabled': profile.planEnabled,
          'model': profile.model,
        },
    ],
    'models': [
      for (final model in models)
        {'slug': model.slug, 'displayName': model.displayName},
    ],
    'accessVerified': accessReceipt != null,
  };

  Future<void> load() {
    if (initialized) return Future<void>.value();
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
    activeAccountId = await credentials.activeSubject();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy || _disposed) return;
    busy = true;
    errorCode = null;
    _notify();
    try {
      await action();
    } on GrokAuthException catch (error) {
      errorCode = error.code;
    } on Object {
      errorCode = 'subscription_operation_failed';
    } finally {
      busy = false;
      devicePrompt = null;
      if (!_disposed) {
        try {
          if (supported) await _reload();
        } on Object {
          profiles = const [];
          activeAccountId = null;
          initialized = false;
        }
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> signIn({String? subject}) => _run(() async {
    accessReceipt = null;
    models = const [];
    final issued = await gateway.signIn(subject: subject);
    await credentials.selectAccount(issued);
    await _reload();
    revocationConfirmed = null;
    await _refreshModels();
  });

  Future<void> signInWithDevice({String? subject}) => _run(() async {
    accessReceipt = null;
    models = const [];
    final issued = await gateway.signInWithDevice(
      subject: subject,
      onPrompt: (prompt) {
        devicePrompt = prompt;
        _notify();
      },
    );
    await credentials.selectAccount(issued);
    await _reload();
    revocationConfirmed = null;
    await _refreshModels();
  });

  Future<void> cancel() => gateway.cancelAccountOperation();

  Future<void> selectAccount(String subject) => _run(() async {
    await credentials.selectAccount(subject);
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
    models = List.unmodifiable(await gateway.models(profile.subject));
  }

  Future<void> selectModel(String model) => _run(() async {
    final subject = activeAccountId;
    if (subject == null || !models.any((entry) => entry.slug == model)) {
      throw const GrokAuthException('model_not_available');
    }
    await credentials.selectModel(subject, model);
    await _reload();
    accessReceipt = null;
  });

  Future<void> verifyAccess() => _run(() async {
    accessReceipt = null;
    final subject = activeAccountId;
    final model = selectedModel;
    if (subject == null ||
        model == null ||
        !models.any((entry) => entry.slug == model)) {
      throw const GrokAuthException('model_required');
    }
    accessReceipt = await gateway.verifyAccess(subject, model);
  });

  Future<void> signOut() => _run(() async {
    final subject = activeAccountId;
    if (subject == null) return;
    accessReceipt = null;
    models = const [];
    revocationConfirmed = await gateway.signOut(subject);
    await _reload();
  });

  @override
  void dispose() {
    _disposed = true;
    unawaited(gateway.dispose());
    super.dispose();
  }
}
