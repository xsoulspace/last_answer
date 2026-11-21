import 'package:oka_store/oka_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// The Huawei AppGallery monetization binding (ADR 0037: one identity,
/// one kernel) — the store identity without a purchase backend: HMS IAP
/// is not shipped yet (roadmap). No backend package is imported; the
/// composition root falls back to `NoopPurchaseProvider`.
final class AppGalleryBinding implements MonetizationStoreBinding {
  /// Const constructor.
  const AppGalleryBinding();

  @override
  StoreKey get key => storeKeyAppGallery;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory => () => null;
}
