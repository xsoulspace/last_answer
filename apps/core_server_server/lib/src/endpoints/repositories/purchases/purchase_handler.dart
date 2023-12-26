import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

/// Generic purchase handler,
/// must be implemented for Google Play and Apple Store
abstract base class PurchaseHandler {
  /// Verify if non-subscription purchase (aka consumable) is valid
  /// and update the database
  Future<bool> handleOneTime({
    required final Session session,
    required final UserModelId userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  });

  /// Verify if subscription purchase (aka non-consumable) is valid
  /// and update the database
  Future<bool> handleSubscription({
    required final Session session,
    required final UserModelId userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  });

  /// Verify if purchase is valid and update the database
  Future<bool> verifyPurchase({
    required final Session session,
    required final UserModelId userId,
    required final PurchaseRequestDtoModel dto,
    required final String token,
  }) async {
    switch (dto.type) {
      case ProductType.subscription:
        return handleSubscription(
          session: session,
          userId: userId,
          dto: dto,
          token: token,
        );
      case ProductType.oneTime:
        return handleOneTime(
          session: session,
          userId: userId,
          dto: dto,
          token: token,
        );
    }
  }
}
