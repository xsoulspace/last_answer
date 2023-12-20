import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core.dart';
import '../services.dart';

final class PurchasesIapGoogleAppleImpl extends PurchasesIap {
  static final _updates = <PurchaseDetails>[];
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

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
  static void subscribe() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _updates.addAll,
    );
  }

  static Future<void> unsubscribe() async => _subscription?.cancel();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  Stream<List<PurchaseDetails>> get stream =>
      InAppPurchase.instance.purchaseStream;

  @override
  Future<bool> buySubscription(final PurchaseParam details) async =>
      InAppPurchase.instance.buyNonConsumable(purchaseParam: details);

  @override
  Future<List<ProductDetails>> getProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(_kIds);
    return response.notFoundIDs.isEmpty ? response.productDetails : [];
  }

  @override
  Future<bool> checkIsStoreAvailable() => InAppPurchase.instance.isAvailable();

  final _kIds = <String>{
    'last_answer_annual_subscription_2022',
    'last_answer_monthly_subscription_2022',
  };

  @override
  void dispose() {
    unawaited(_purchaseSubscription?.cancel());
    super.dispose();
  }
}
