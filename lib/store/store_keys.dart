/// Last Answer's store names (oka ADR-0055/0056).
///
/// A store name is an open-set string: oka's `StoreKey` type composes the
/// BUILD side (delivery variants, validated in `tool/oka_pipeline.dart`);
/// the RUNTIME side names stores by the same string and joins to the build
/// through the `OKA_STORE` dart-define (verified at boot in
/// `lib/bootstrap.dart`). Per ADR-0056 the app must not depend on oka
/// channel packages just to name a store — the names are composed here,
/// in the store layer, once.
///
/// Nothing in the app switches on these names directly: UI reads the
/// named capabilities in `store_posture.dart`; bindings in
/// `bindings/` carry them.
library;

/// The store-neutral name (dev, website, snap-less desktop builds).
const storeNameNoop = 'noop';

/// Google Play.
const storeKeyGooglePlay = 'google-play';

/// RuStore.
const storeKeyRuStore = 'rustore';

/// Huawei AppGallery.
const storeKeyAppGallery = 'appgallery';

/// Apple App Store.
const storeKeyAppleStore = 'apple-store';

/// Snap Store (Linux).
const storeKeySnapStore = 'snapstore';
