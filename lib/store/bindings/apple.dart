import 'dart:io';

import 'package:oka_store/oka_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_google_apple/xsoulspace_monetization_google_apple.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// The Apple App Store monetization binding — iOS and macOS (ADR 0037:
/// one identity, one kernel).
///
/// This file is the ONLY place in the app where the google/apple backend
/// package is imported for the Apple delivery — the per-store entrypoint
/// (`lib/entrypoints/main_store_apple.dart`) imports exactly this
/// binding. macOS App Store purchases ride the same StoreKit path, hence
/// `isIOS` is `iOS || macOS` (the provider's apple-native branches gate
/// on it).
final class AppleBinding implements MonetizationStoreBinding {
  /// Const constructor.
  const AppleBinding();

  @override
  StoreKey get key => storeKeyAppleStore;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory =>
      () => GoogleApplePurchaseProvider(
        isIOS: () => Platform.isIOS || Platform.isMacOS,
      );
}
