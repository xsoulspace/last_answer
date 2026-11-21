import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// The store-neutral monetization binding (ADR 0037): dev builds, the
/// xsoulspace website, snap and other store-less channels. No backend
/// package is imported — the composition root falls back to
/// `NoopPurchaseProvider`.
const noopStoreBinding = NoopMonetizationStoreBinding();
