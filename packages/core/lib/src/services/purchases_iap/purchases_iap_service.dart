import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import 'purchases_iap_google_apple.dart';

export 'purchases_iap_google_apple.dart';

abstract base class PurchasesIapService extends ChangeNotifier {
  Future<bool> checkIsStoreAvailable();
  Future<void> completePurchase(final PurchaseDetails details);
  Future<bool> buyNonConsumable(final PurchaseParam details);
  Future<void> restorePurchases(final UserModelId userId);
  Future<List<ProductDetails>> getProducts();
  static PurchasesIapGoogleAppleImpl ofContextAsGoogleAppleImpl(
    final BuildContext context,
  ) =>
      context.read<PurchasesIapService>() as PurchasesIapGoogleAppleImpl;
}
