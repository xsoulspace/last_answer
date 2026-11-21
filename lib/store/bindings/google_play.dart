import 'package:oka_store/oka_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_google_apple/xsoulspace_monetization_google_apple.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// The Google Play monetization binding (ADR 0037: one identity, one
/// kernel).
///
/// This file is the ONLY place in the app where the google/apple backend
/// package is imported for the Play delivery — the per-store entrypoint
/// (`lib/entrypoints/main_store_google_play.dart`) imports exactly this
/// binding. Android-only posture: `isIOS` is pinned false so the
/// StoreKit branches are dead code in a Play kernel.
final class GooglePlayBinding implements MonetizationStoreBinding {
  /// Const constructor.
  const GooglePlayBinding();

  @override
  StoreKey get key => storeKeyGooglePlay;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory =>
      () => GoogleApplePurchaseProvider(isIOS: () => false);
}
