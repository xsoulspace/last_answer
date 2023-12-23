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
    final ProductModelId productId,
    final String verificationData,
    final PurchasePaymentProvider provider,
  ) async =>
      null;
}

/// Generic purchase handler,
/// must be implemented for Google Play and Apple Store
abstract class PurchaseHandler {
  /// Verify if non-subscription purchase (aka consumable) is valid
  /// and update the database
  Future<bool> handleOneTime({
    required final String userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  });

  /// Verify if subscription purchase (aka non-consumable) is valid
  /// and update the database
  Future<bool> handleSubscription({
    required final String userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  });

  /// Verify if purchase is valid and update the database
  Future<bool> verifyPurchase({
    required final String userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  }) async {
    switch (dto.type) {
      case ProductType.subscription:
        return handleSubscription(
          userId: userId,
          dto: dto,
          token: token,
        );
      case ProductType.oneTime:
        return handleOneTime(
          userId: userId,
          dto: dto,
          token: token,
        );
    }
  }
}
