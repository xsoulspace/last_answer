import 'package:flutter/foundation.dart';
import 'package:xsoulspace_installation_store/xsoulspace_installation_store.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

import '../../envs.dart';

/// Prefixes:
/// s - subscription
/// c - consumable
/// n - non-consumable
enum MonetizationProducts {
  sYear('la_year_1'),
  sMonth1('la_month_1'),
  sMonth3('la_month_3'),
  sDay1Test('la_day_1_test');

  const MonetizationProducts(this._productId);
  final String _productId;
  PurchaseProductId get productId => PurchaseProductId.fromJson(_productId);

  static final subscriptions = values
      .where((final e) => e.name.startsWith('s'))
      .map((final e) => e.productId)
      .toList();

  static List<PurchaseProductId> get subscriptionsForBuild =>
      kDebugMode ? subscriptions : subscriptions;

  static PurchaseProductType? productTypeChecker(
    final PurchaseProductId productId,
  ) => MonetizationProducts.subscriptions.contains(productId)
      ? PurchaseProductType.subscription
      : null;

  static MonetizationProducts? fromProductId(final PurchaseProductId id) {
    for (final p in values) {
      if (p.productId == id) return p;
    }
    return null;
  }
}

/// User-facing disclosure labels.
extension MonetizationProductsDisclosure on MonetizationProducts {
  String title() => switch (this) {
    MonetizationProducts.sMonth1 => 'Last Answer Pro — Monthly',
    MonetizationProducts.sMonth3 => 'Last Answer Pro — 3 Months',
    MonetizationProducts.sYear => 'Last Answer Pro — Yearly',
    MonetizationProducts.sDay1Test => 'Last Answer Pro — 1 Day (Test)',
  };

  String lengthLabel() => switch (this) {
    MonetizationProducts.sMonth1 => '1 month',
    MonetizationProducts.sMonth3 => '3 months',
    MonetizationProducts.sYear => '1 year',
    MonetizationProducts.sDay1Test => '1 day',
  };

  String perPeriodLabel() => switch (this) {
    MonetizationProducts.sMonth1 => 'per month',
    MonetizationProducts.sMonth3 => 'per 3 months',
    MonetizationProducts.sYear => 'per year',
    MonetizationProducts.sDay1Test => 'per day',
  };
}

/// Store target used by monetization UI.
InstallationTargetStore get monetizationStoreTarget => switch (Envs.store) {
  StoreType.rustore => InstallationTargetStore.rustore,
  StoreType.googlePlay => InstallationTargetStore.mobileGooglePlay,
  StoreType.appleStore => InstallationTargetStore.mobileAppleAppStore,
  StoreType.huawaiStore => InstallationTargetStore.huawei,
  _ => InstallationTargetStore.rustore,
};

/// RuStore console application id.
const rustoreApplicationId = '2045332927';

/// Deeplink scheme used by RuStore billing callbacks.
const appDeeplinkScheme = 'dev.xsoulspace.lastanswer';
