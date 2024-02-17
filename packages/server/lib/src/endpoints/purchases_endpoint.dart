import 'package:server/src/extensions/extensions.dart';
import 'package:server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

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
      isOneTimePurchased: initial.isOneTimePurchased,
      daysOfSupporterLeft: initial.daysOfSupporterLeft,
      subscriptionEndDate: initial.subscriptionEndDate,
      userId: userId,
    );

    await UserPurchaseInfo.db.insertRow(session, newPurchases);

    return newPurchases;
  }

  Future<void> recordPurchase(
    final Session session,
  ) async {
    throw UnimplementedError();
    // final userId = await session.userId;
    // UserPurchaseInfo? info = await UserPurchaseInfo.db.findFirstRow(
    //   session,
    //   where: (final p0) => p0.userId.equals(userId),
    // );
    // info ??= await createPurchaseInfo(session);
    // await UserPurchaseInfo.db.insertRow(session, updatedInfo);
  }

  Future<PurchaseActionModel?> verifyNativeMobilePurchase({
    required final Session session,
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  }) {
    throw UnimplementedError();
  }

  Future<PurchasesModel> getPurchases({
    required final Session session,
  }) {
    throw UnimplementedError();
  }

  Future<PurchasesModel> mergeLocalPurchases({
    required final Session session,
    required final PurchasesModel purchases,
  }) {
    // final serverPurchases =
    // final updatedPurchases = purchase.mergeWith(other);
    throw UnimplementedError();
  }
}
