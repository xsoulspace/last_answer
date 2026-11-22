import 'package:flutter/foundation.dart';
import 'package:lastanswer/data_monetization/monetization.dart';
import 'package:lastanswer/store/store_keys.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';
import 'package:xsoulspace_monetization_rustore/xsoulspace_monetization_rustore.dart';

/// The RuStore console application id.
const rustoreApplicationId = '2045332927';

/// Deeplink scheme used by RuStore billing callbacks.
const appDeeplinkScheme = 'dev.xsoulspace.lastanswer';

/// The RuStore monetization binding (ADR 0037: one identity, one kernel).
///
/// This file is the ONLY place in the app where the rustore backend
/// package is imported — the per-store entrypoint
/// (`lib/entrypoints/main_store_rustore.dart`) imports exactly this
/// binding, so only the rustore purchase backend compiles into that
/// build's AOT kernel.
final class RuStoreBinding implements MonetizationStoreBinding {
  /// Const constructor.
  const RuStoreBinding();

  @override
  String get key => storeKeyRuStore;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory =>
      () => RustorePurchaseProvider(
        consoleApplicationId: rustoreApplicationId,
        deeplinkScheme: appDeeplinkScheme,
        enableLogging: kDebugMode,
        productTypeChecker: MonetizationProducts.productTypeChecker,
      );
}
