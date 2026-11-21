import 'package:oka_store/oka_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// The Snap Store monetization binding (ADR 0037: one identity, one
/// kernel) — the store identity without a purchase backend (snap
/// distribution rides the desktop build; no snap-specific billing). No
/// backend package is imported; the composition root falls back to
/// `NoopPurchaseProvider`.
final class SnapBinding implements MonetizationStoreBinding {
  /// Const constructor.
  const SnapBinding();

  @override
  StoreKey get key => storeKeySnapStore;

  @override
  PurchaseProvider? Function() get purchaseProviderFactory => () => null;
}
