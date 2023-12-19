import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core.dart';
import '../services.dart';

final class PurchasesIapGoogleAppleImpl extends PurchasesIap {
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
