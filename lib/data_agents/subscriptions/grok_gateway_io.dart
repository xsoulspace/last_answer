import 'dart:io';

import 'package:lastanswer/data_agents/subscriptions/chatgpt_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_credentials.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway_contract.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_xai/xsoulspace_inference_xai.dart';

GrokGateway createGrokGateway(GrokCredentials credentials) =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux
    ? NativeGrokGateway(credentials: credentials)
    : UnsupportedGrokGateway();

final class NativeGrokGateway implements GrokGateway {
  NativeGrokGateway({
    required this.credentials,
    GrokAuth? auth,
    SubscriptionBrowserLauncher? openBrowser,
  }) : auth =
           auth ??
           GrokAuth(
             store: credentials,
             registration: LastAnswerGrokRegistration.fromEnvironment(),
           ),
       _openBrowser = openBrowser ?? _launchBrowser;

  final GrokCredentials credentials;
  final GrokAuth auth;
  final SubscriptionBrowserLauncher _openBrowser;
  final _clients = <GrokResponsesClient, String>{};
  GrokLoopback? _listener;
  GrokDeviceAttempt? _device;
  bool _disposed = false;
  bool _authorizing = false;
  int _epoch = 0;

  @override
  bool get supported => !_disposed;
  @override
  bool get registered => auth.registration.isRegistered;
  @override
  LastAnswerGrokRegistration get registration => auth.registration;

  static Future<void> _launchBrowser(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const GrokAuthException('browser_open_failed');
    }
  }

  void _requireIdle(int epoch) {
    if (_disposed || epoch != _epoch) {
      throw const GrokAuthException('authorization_cancelled');
    }
    if (!registered) throw const GrokAuthException('client_not_registered');
  }

  @override
  Future<String> signIn({String? subject}) async {
    if (_disposed || _authorizing) {
      throw const GrokAuthException('authorization_busy');
    }
    _authorizing = true;
    final epoch = _epoch;
    try {
      _requireIdle(epoch);
      String? hint;
      if (subject != null) {
        final profiles = await credentials.profiles();
        for (final profile in profiles) {
          if (profile.subject == subject) hint = profile.email;
        }
      }
      final listener = await GrokLoopback.bind();
      if (_disposed || epoch != _epoch) {
        await listener.close();
        throw const GrokAuthException('authorization_cancelled');
      }
      _listener = listener;
      try {
        final account = await listener.authorize(
          auth: auth,
          openBrowser: _openBrowser,
          expectedSubject: subject,
          loginHint: hint,
        );
        return account.subject;
      } finally {
        if (identical(_listener, listener)) _listener = null;
      }
    } finally {
      _authorizing = false;
    }
  }

  @override
  Future<String> signInWithDevice({
    required void Function(GrokDevicePrompt prompt) onPrompt,
    String? subject,
  }) async {
    if (_disposed || _authorizing) {
      throw const GrokAuthException('authorization_busy');
    }
    _authorizing = true;
    final epoch = _epoch;
    try {
      _requireIdle(epoch);
      final attempt = await auth.beginDevice(expectedSubject: subject);
      if (_disposed || epoch != _epoch) {
        attempt.cancelled = true;
        throw const GrokAuthException('authorization_cancelled');
      }
      _device = attempt;
      onPrompt(attempt.prompt);
      try {
        return (await auth.completeDevice(attempt)).subject;
      } finally {
        if (identical(_device, attempt)) _device = null;
      }
    } finally {
      _authorizing = false;
    }
  }

  @override
  Future<void> cancelSignIn() async {
    _epoch++;
    _device?.cancelled = true;
    await _listener?.close();
  }

  @override
  Future<void> cancelAccountOperation() async {
    await cancelSignIn();
    for (final client in _clients.keys.toList()) {
      client.cancelActive();
    }
    await Future.wait(_clients.keys.map((client) => client.settleActive()));
  }

  @override
  Future<bool> signOut(String subject) async {
    final clients = _clients.entries
        .where((entry) => entry.value == subject)
        .map((entry) => entry.key)
        .toList();
    for (final client in clients) {
      client.cancelActive();
    }
    await Future.wait(clients.map((client) => client.settleActive()));
    for (final client in clients) {
      await releaseClient(client);
    }
    return auth.signOut(subject);
  }

  GrokResponsesClient _client(String subject, String model) {
    if (_disposed) throw const GrokAuthException('gateway_disposed');
    final client = GrokResponsesClient(
      auth: auth,
      subject: subject,
      model: model,
    );
    _clients[client] = subject;
    return client;
  }

  @override
  InferenceClient inferenceClient(String subject, String model) =>
      _client(subject, model);

  @override
  Future<void> releaseClient(InferenceClient client) async {
    if (client is! GrokResponsesClient || _clients.remove(client) == null) {
      return;
    }
    client.cancelActive();
    await client.settleActive();
    client.close();
  }

  @override
  Future<List<SubscriptionModel>> models(String subject) async {
    final client = _client(subject, '');
    try {
      return [
        for (final model in await client.listModels())
          SubscriptionModel(slug: model.slug, displayName: model.displayName),
      ];
    } finally {
      await releaseClient(client);
    }
  }

  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String subject,
    String model,
  ) async {
    final client = _client(subject, model);
    try {
      final result = await client.infer(
        InferenceRequest(prompt: 'Say exactly: Ready.', reasoningEffort: 'low'),
      );
      if (!result.success || result.data == null) {
        throw GrokAuthException(result.error?.code ?? 'response_failed');
      }
      final meta = result.data!.meta;
      final usage = meta['usage'];
      return SubscriptionAccessReceipt(
        model: model,
        responseId: meta['response_id'] as String? ?? '',
        usage: usage is Map ? usage.cast<String, Object?>() : const {},
      );
    } finally {
      await releaseClient(client);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await cancelSignIn();
    for (final client in _clients.keys.toList()) {
      client.cancelActive();
      await client.settleActive();
      client.close();
    }
    _clients.clear();
    auth.close();
  }
}

/// Mobile and other non-desktop targets that still compile this file.
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
