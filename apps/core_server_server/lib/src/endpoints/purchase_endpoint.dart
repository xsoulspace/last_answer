import 'package:core_server_server/src/generated/purchase.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

/// API to make or cancel purchase
class PurchaseEndpoint extends Endpoint {
  Future<bool> buySubscription(
    final Session session,
    final Purchase purchaseId,
  ) async =>
      false;
  Future<bool> cancelSubscriptionAutorenew(
    final Session session,
    final int purchaseId,
  ) async =>
      false;
  Future<bool> resumeSubscriptionAutorenew(
    final Session session,
    final int purchaseId,
  ) async =>
      false;
  Future<PurchaseModel?> verifyNativeMobilePurchase(
    final Session session,
    final IAPId productId,
    final String verificationData,
    final PurchasePaymentProvider provider,
  ) async =>
      null;
}
