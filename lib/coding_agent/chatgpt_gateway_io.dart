import 'dart:io';

import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_stub.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/xsoulspace_inference_openai.dart';

ChatGptGateway createChatGptGateway(
  ChatGptCredentials credentials, {
  ContextTransportDiagnosticCapture? Function()? diagnosticCaptureForClient,
}) => Platform.isMacOS || Platform.isWindows || Platform.isLinux
    ? NativeChatGptGateway(
        credentials: credentials,
        diagnosticCaptureForClient: diagnosticCaptureForClient,
      )
    : UnsupportedChatGptGateway();

final class NativeChatGptGateway
    implements ChatGptGateway, ChatGptTransportDiagnostics {
  NativeChatGptGateway({
    required this.credentials,
    ChatGptAuth? auth,
    SubscriptionBrowserLauncher? openBrowser,
    this.diagnosticCaptureForClient,
  }) : auth = auth ?? ChatGptAuth(store: credentials),
       _openBrowser = openBrowser ?? _launchBrowser;

  final ChatGptCredentials credentials;

  /// Optional per-client diagnostics; absent for ordinary actor/account casts.
  final ContextTransportDiagnosticCapture? Function()?
  diagnosticCaptureForClient;
  final ChatGptAuth auth;
  final SubscriptionBrowserLauncher _openBrowser;
  final _clients = <OpenAiResponsesClient, String>{};
  final _inferenceSessionState = OpenAiSessionState();
  final _accountOperations = <OpenAiResponsesClient>{};
  final _signingOut = <String>{};
  final _transportDecisions =
      <({String operation, ResponsesDecisionReceipt receipt})>[];
  @override
  List<Map<String, Object?>> get transportDecisions => List.unmodifiable(
    _transportDecisions.map(
      (entry) => {'operation': entry.operation, ...entry.receipt.toJson()},
    ),
  );
  ChatGptLoopback? _listener;
  bool _disposed = false;
  bool _authorizing = false;
  int _authorizationEpoch = 0;
  @override
  bool get supported => !_disposed;
  @override
  bool get hasUnconfirmedCleanup => auth.hasUnconfirmedAuthorizationCleanup;

  static Future<void> _launchBrowser(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const ChatGptAuthException('browser_open_failed');
    }
  }

  @override
  Future<String> signIn({String? clientId}) async {
    if (_disposed || _authorizing) {
      throw const ChatGptAuthException('authorization_busy');
    }
    _authorizing = true;
    final epoch = _authorizationEpoch;
    try {
      final hostId = await credentials.ensureHostId();
      final registration = clientId == null
          ? null
          : await credentials.registration(clientId);
      if (clientId != null && registration == null) {
        throw const ChatGptAuthException('registration_missing');
      }
      if (_disposed || epoch != _authorizationEpoch) {
        throw const ChatGptAuthException('authorization_cancelled');
      }
      final listener = await ChatGptLoopback.bind();
      if (_disposed || epoch != _authorizationEpoch) {
        await listener.close();
        throw const ChatGptAuthException('authorization_cancelled');
      }
      _listener = listener;
      try {
        final account = await listener.authorize(
          auth: auth,
          hostId: hostId,
          appName: 'Last Answer',
          registration: registration,
          openBrowser: _openBrowser,
        );
        _signingOut.remove(account.clientId);
        return account.clientId;
      } finally {
        if (identical(_listener, listener)) _listener = null;
      }
    } finally {
      _authorizing = false;
    }
  }

  @override
  Future<void> cancelSignIn() async {
    _authorizationEpoch++;
    await _listener?.close();
  }

  @override
  Future<void> cancelAccountOperation() async {
    await cancelSignIn();
    final clients = _accountOperations.toList();
    for (final client in clients) {
      client.cancelActive();
    }
    await Future.wait(clients.map((client) => client.settleActive()));
  }

  @override
  Future<bool> signOut(String clientId) async {
    _inferenceSessionState.clear();
    _signingOut.add(clientId);
    final clients = _clients.entries
        .where((entry) => entry.value == clientId)
        .map((entry) => entry.key)
        .toList();
    for (final client in clients) {
      client.cancelActive();
    }
    await Future.wait(clients.map((client) => client.settleActive()));
    for (final client in clients) {
      await releaseClient(client);
    }
    return auth.signOut(clientId);
  }

  OpenAiResponsesClient _client(String clientId, String model) {
    if (_disposed) throw const ChatGptAuthException('gateway_disposed');
    if (_signingOut.contains(clientId)) {
      throw const ChatGptAuthException('sign_in_required');
    }
    late final OpenAiResponsesClient client;
    client = OpenAiResponsesClient(
      auth: auth,
      clientId: clientId,
      model: model,
      diagnosticCapture: diagnosticCaptureForClient?.call(),
      sessionState: _inferenceSessionState,
      observeDecision: (receipt) {
        _transportDecisions.add((
          operation: _accountOperations.contains(client) ? 'account' : 'actor',
          receipt: receipt,
        ));
        if (_transportDecisions.length > 16) _transportDecisions.removeAt(0);
      },
    );
    _clients[client] = clientId;
    return client;
  }

  @override
  InferenceClient inferenceClient(String clientId, String model) =>
      _client(clientId, model);

  @override
  Future<void> releaseClient(InferenceClient client) async {
    if (client is! OpenAiResponsesClient || _clients.remove(client) == null) {
      return;
    }
    client.cancelActive();
    await client.settleActive();
    client.close();
  }

  @override
  Future<List<SubscriptionModel>> models(String clientId) async {
    final client = _client(clientId, '');
    _accountOperations.add(client);
    try {
      return (await client.listModels())
          .map(
            (model) => SubscriptionModel(
              slug: model.slug,
              displayName: model.displayName,
            ),
          )
          .toList(growable: false);
    } finally {
      _accountOperations.remove(client);
      await releaseClient(client);
    }
  }

  @override
  Future<SubscriptionAccessReceipt> verifyAccess(
    String clientId,
    String model,
  ) async {
    final client = _client(clientId, model);
    _accountOperations.add(client);
    try {
      final result = await client.infer(
        InferenceRequest(prompt: 'Say exactly: Ready.', reasoningEffort: 'low'),
      );
      if (!result.success || result.data == null) {
        throw ChatGptAuthException(result.error?.code ?? 'response_failed');
      }
      final meta = result.data!.meta;
      return SubscriptionAccessReceipt(
        model: model,
        responseId: meta['response_id'] as String? ?? '',
        usage: (meta['usage'] as Map?)?.cast<String, Object?>() ?? const {},
      );
    } finally {
      _accountOperations.remove(client);
      await releaseClient(client);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _inferenceSessionState.clear();
    await cancelSignIn();
    for (final client in _clients.keys.toList()) {
      client.cancelActive();
    }
    await Future.wait(_clients.keys.map((client) => client.settleActive()));
    for (final client in _clients.keys.toList()) {
      client.close();
    }
    _clients.clear();
    auth.close();
  }
}
