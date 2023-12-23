import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';
import '../services.dart';

/// Sources:
/// https://codelabs.developers.google.com/codelabs/flutter-in-app-purchases#9
final class PurchasesIapGoogleAppleImpl extends PurchasesIap {
  /// IMPORTANT! You must subscribe to this stream as soon as your
  /// app launches, preferably before returning your main App Widget
  /// in main(). Otherwise you will miss purchase updated made
  /// before this stream is subscribed to.
  ///
  /// We also recommend listening to the stream with one
  /// subscription at a given time. If you choose to have
  /// multiple subscription at the same time, you should be
  /// careful at the fact that each subscription will receive
  /// all the events after they start to listen.

  Stream<List<PurchaseDetails>> get stream =>
      InAppPurchase.instance.purchaseStream;

  @override
  Future<bool> buyNonConsumable(final PurchaseParam details) async =>
      InAppPurchase.instance.buyNonConsumable(purchaseParam: details);

  @override
  Future<void> completePurchase(final PurchaseDetails details) async =>
      InAppPurchase.instance.completePurchase(details);

  @override
  Future<void> restorePurchases(final UserModelId userId) async =>
      InAppPurchase.instance
          .restorePurchases(applicationUserName: userId.value);

  @override
  Future<List<ProductDetails>> getProducts() async {
    final response =
        await InAppPurchase.instance.queryProductDetails(IAPId.ids);
    for (final purchase in response.notFoundIDs) {
      debugPrint('Purchase $purchase not found');
    }
    return response.productDetails;
  }

  @override
  Future<bool> checkIsStoreAvailable() => InAppPurchase.instance.isAvailable();
}

enum IAPId {
  // 'last_answer_annual_subscription_2022',
  // 'last_answer_monthly_subscription_2022',
  proOneTimePurchase('pro_one_time_purchase');

  const IAPId(this.id);
  factory IAPId.byId(final String id) {
    final maybeId = IAPId.values.firstWhereOrNull((final e) => e.id == id);
    if (maybeId == null) {
      throw ArgumentError.value('$id is not a known product');
    }
    return maybeId;
  }
  final String id;
  static final ids = IAPId.values.map((final e) => e.id).toSet();
}
