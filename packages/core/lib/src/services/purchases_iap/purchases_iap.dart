import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'purchases_iap_google_apple.dart';

export 'purchases_iap_google_apple.dart';

abstract base class PurchasesIap extends ChangeNotifier {
  Future<bool> checkIsStoreAvailable();
  Future<bool> buySubscription(final PurchaseParam details);
  Future<List<ProductDetails>> getProducts();

  static PurchasesIapGoogleAppleImpl ofContextAsGoogleAppleImpl(
    final BuildContext context,
  ) =>
      context.read<PurchasesIap>() as PurchasesIapGoogleAppleImpl;
}
