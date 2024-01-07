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
    final purchases = await Purchases.findSingleRow(
      session,
      where: (final p0) => p0.userId.equals(userId),
      useCache: false,
    );
    if (purchases != null) return;
    const initial = PurchasesModel.empty;
    final newPurchases = Purchases(
      has_one_time_purchase: initial.hasOneTimePurchase,
      purchased_days_left: initial.purchasedDaysLeft,
      subscription_end_date: initial.subscriptionEndDate,
      userId: userId,
    );

    await Purchases.insert(session, newPurchases);
  }
}
