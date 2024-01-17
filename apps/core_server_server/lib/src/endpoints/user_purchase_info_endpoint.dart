import 'package:core_server_server/src/extensions/extensions.dart';
import 'package:core_server_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

/// API to get information about purchases
class UserPurchaseInfoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  final _logic = UserPurchaseInfoEndpointImpl();

  Future<void> create(final Session session) async =>
      _logic.createPurchaseInfo(session);
}

/// Standalone implementation to use same logic
/// in other endpoints
class UserPurchaseInfoEndpointImpl {
  /// Use to create user purchase info
  Future<UserPurchaseInfo> createPurchaseInfo(final Session session) async {
    final userId = await session.userId;
    final info = await UserPurchaseInfo.db.findFirstRow(
      session,
      where: (final p0) => p0.userId.equals(userId),
    );
    if (info != null) return info;
    const initial = PurchasesModel.empty;
    final newPurchases = UserPurchaseInfo(
      hasOneTimePurchase: initial.hasOneTimePurchase,
      purchasedDaysLeft: initial.purchasedDaysLeft,
      subscriptionEndDate: initial.subscriptionEndDate,
      userId: userId,
    );

    await UserPurchaseInfo.db.insertRow(session, newPurchases);

    return newPurchases;
  }

  Future<void> receiveAdVideoReward(
    final Session session,
  ) async {
    final userId = await session.userId;
    UserPurchaseInfo? info = await UserPurchaseInfo.db.findFirstRow(
      session,
      where: (final p0) => p0.userId.equals(userId),
    );
    info ??= await createPurchaseInfo(session);

    final updatedInfo = info.copyWith(
      purchasedDaysLeft: info.purchasedDaysLeft + 7,
    );

    await UserPurchaseInfo.db.insertRow(session, updatedInfo);
  }
}
