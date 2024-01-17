import 'package:core_server_server/src/extensions/extensions.dart';
import 'package:core_server_server/src/generated/purchases.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

/// API to get information about purchases
class PurchasesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> createPurchases(
    final Session session,
  ) async =>
      PurchasesEndpointImpl().createPurchases(session);
}

/// Standalone implementation to use same logic
/// in other endpoints
class PurchasesEndpointImpl {
  Future<void> createPurchases(
    final Session session,
  ) async {
    final userId = await session.userId;
    final purchases = await Purchases.db.findFirstRow(
      session,
      where: (final p0) => p0.userId.equals(userId),
    );
    if (purchases != null) return;
    const initial = PurchasesModel.empty;
    final newPurchases = Purchases(
      hasOneTimePurchase: initial.hasOneTimePurchase,
      purchasedDaysLeft: initial.purchasedDaysLeft,
      subscriptionEndDate: initial.subscriptionEndDate,
      userId: userId,
    );

    await Purchases.db.insert(session, [newPurchases]);
  }
}
