import 'package:core/core.dart';
import 'package:core_server_server/src/extensions/extensions.dart';
import 'package:core_server_server/src/generated/purchases.dart';
import 'package:serverpod/serverpod.dart';

class PurchasesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> createPurchases(
    final Session session,
  ) async =>
      PurchasesEndpointImpl().createPurchases(session);
}

class PurchasesEndpointImpl {
  Future<void> createPurchases(
    final Session session,
  ) async {
    final userId = await session.userId;
    final existedPurchases = await Purchases.findById(session, userId);
    if (existedPurchases != null) return;
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
