import 'package:core_server_server/src/generated/purchase.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

class PurchaseEndpoint extends Endpoint {
  Future<bool> setSubscription(
    final Session session,
    final Purchase purchaseId,
  ) async =>
      false;
  Future<bool> cancelAutorenew(
    final Session session,
    final int purchaseId,
  ) async =>
      false;
  Future<bool> resumeAutorenew(
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
