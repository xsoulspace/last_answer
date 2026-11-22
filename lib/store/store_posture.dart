import 'package:lastanswer/store/store_keys.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// Last Answer's product posture over the kernel's store binding
/// (ADR 0037 amendment): the UI reads NAMED capabilities and never
/// compares store keys — the key→posture mapping lives in exactly one
/// file, in the store layer, where store names belong.
///
/// The capabilities are product policy keyed to store identity (today
/// both map to the RuStore key); naming them keeps call sites honest
/// about what they actually branch on, and a future store serving the
/// same posture is one edit here, not a sweep across UI files.
extension StorePosture on MonetizationStoreBinding {
  /// This store's purchase flow requires a store-account login before
  /// purchases work (the RuStore authorization wall).
  bool get requiresStoreLogin => key == storeKeyRuStore;

  /// This build serves the RU market posture — the per-network character
  /// limits product rule (RuStore distribution is the store half; the
  /// `ru` locale is the runtime half).
  bool get isRuMarket => key == storeKeyRuStore;
}
