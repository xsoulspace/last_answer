import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

final class SubscriptionModel {
  const SubscriptionModel({required this.slug, required this.displayName});
  final String slug;
  final String displayName;
}

final class SubscriptionAccessReceipt {
  const SubscriptionAccessReceipt({
    required this.model,
    required this.responseId,
    required this.usage,
  });
  final String model;
  final String responseId;
  final Map<String, Object?> usage;
}

/// One application-owned account/transport owner. Tokens stay behind this seam.
abstract interface class ChatGptGateway {
  bool get supported;
  bool get hasUnconfirmedCleanup;
  Future<String> signIn({String? clientId});
  Future<void> cancelSignIn();
  Future<void> cancelAccountOperation();
  Future<bool> signOut(String clientId);
  Future<List<SubscriptionModel>> models(String clientId);
  Future<SubscriptionAccessReceipt> verifyAccess(String clientId, String model);
  InferenceClient inferenceClient(String clientId, String model);
  Future<void> releaseClient(InferenceClient client);
  Future<void> dispose();
}

typedef SubscriptionBrowserLauncher = Future<void> Function(Uri uri);

/// Optional bounded transport diagnostics, independent of account authority.
abstract interface class ChatGptTransportDiagnostics {
  List<Map<String, Object?>> get transportDecisions;
}
