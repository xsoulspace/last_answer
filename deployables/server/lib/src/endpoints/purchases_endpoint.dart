import 'package:server/src/extensions/extensions.dart';
import 'package:server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API to get information about purchases
class PurchasesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  final _logic = PurchasesEndpointImpl();

  Future<void> create(final Session session) async =>
      _logic.createPurchaseInfo(session);
}

/// Standalone implementation to use same logic
/// in other endpoints
class PurchasesEndpointImpl {
  /// Use to create user purchase info. The seed is the empty purchase
  /// state (ADR 0037 dissolved the legacy supporter-days model): no
  /// one-time purchase, no subscription, zero supporter days.
  Future<UserPurchaseInfo> createPurchaseInfo(final Session session) async {
    final userId = await session.userId;
    final info = await UserPurchaseInfo.db.findFirstRow(
      session,
      where: (final p0) => p0.userId.equals(userId),
    );
    if (info != null) return info;
    final newPurchases = UserPurchaseInfo(
      isOneTimePurchased: false,
      daysOfSupporterLeft: 0,
      userId: userId,
    );

    await UserPurchaseInfo.db.insertRow(session, newPurchases);

    return newPurchases;
  }
}
