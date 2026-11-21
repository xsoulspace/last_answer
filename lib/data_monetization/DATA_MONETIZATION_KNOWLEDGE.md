# DATA_MONETIZATION_KNOWLEDGE.md

**Owns:** the monetization concern — the product catalog
(`monetization.dart`, `MonetizationProducts`), the entitlement seam
(`pro_entitlement.dart`), the ads data sources/notifier, and the legacy
purchase data sources still referenced by the ads lane.

## Store identity — one binding per kernel (ADR 0037)

The store a build ships for is **not** an env var and **not** an enum.
`lib/store/bindings/` holds hand-typed `MonetizationStoreBinding`s (oka
ADR 0055's open `StoreKey` + a nullable `purchaseProviderFactory`);
`lib/entrypoints/main_store_<x>.dart` imports exactly ONE binding, and
`bootstrap(storeBinding: …)` threads it to `GlobalStatesProvider` — so
only that backend's code compiles into the kernel. Backend packages are
imported **only** inside `lib/store/bindings/` (enforced by
`just store-gates`); everything else reads named posture capabilities —
`requiresStoreLogin` / `isRuMarket` from `lib/store/store_posture.dart`
— or the open `StoreKey` (from `oka_store`). Each delivery bakes its
store key as the `OKA_STORE` dart define; `bootstrap` refuses to boot a
binding that names a different store.

| delivery (`oka run …`) | store key | binding | entrypoint | channel |
|---|---|---|---|---|
| `app-google-play` | `google-play` | `GooglePlayBinding` | `main_store_google_play.dart` | `PlayPublishTarget` (dry-run) |
| `app-rustore` | `rustore` | `RuStoreBinding` | `main_store_rustore.dart` | `RuStorePublishTarget` (dry-run) |
| `app-appgallery` | `appgallery` | `AppGalleryBinding` (identity, no HMS IAP yet) + `hmsFree` overlay | `main_store_appgallery.dart` | `HuaweiPublishTarget` (dry-run) |
| `app-apple-store` | `apple-store` | `AppleBinding` (iOS + macOS StoreKit) | `main_store_apple.dart` | — (roadmap) |
| `app-snap` | `snapstore` | `SnapBinding` (identity, no snap billing) | `main_store_snap.dart` | — (roadmap) |
| dev / website / windows | `noop` | `noopStoreBinding` | `lib/main.dart` | — |

Deliveries live in `tool/oka_pipeline.dart` (oka ADR 0055: pipeline by
const reference + variant + channel; composition-time legality — AppGallery
prohibits the `gms` overlay). The old `Envs.store` / `StoreType` enum is
gone.

## Native store setup (checklists)

- **Google Play** (`la_month_1`, `la_month_3`, `la_year_1`): create the
  subscription products in Play Console; add license testers; publishing
  credentials = service-account JSON by path (see
  `tool/oka_pipeline.dart` `playPublishTarget` doc for the full
  walkthrough).
- **RuStore** (`consoleApplicationId: 2045332927`, deeplink scheme
  `dev.xsoulspace.lastanswer`): products mirror the Play ids; the upload
  adapter is still a readiness plan (dry-run) until the store API client
  lands.
- **Apple** (iOS + macOS): App Store Connect subscriptions with matching
  product ids; Xcode In-App Purchase capability; StoreKit configuration
  for local testing. The provider gates apple-native branches on
  `iOS || macOS`.
- **Snap / Windows / website**: honest `NoopPurchaseProvider` — the
  paywall renders the store's own `notAvailable` fact; no paywall entry
  hiding.

## State placement

Purchase/subscription state rides the `xsoulspace_monetization_foundation`
resources (provided in `ui_root/global_states_provider.dart`); the
entitlement seam (`ProEntitlement`, `isSubscribed OR dev-override`) sits
above them. Cold state stays notifier-backed (ADR 0036: ECS is for hot
paths, not settings). The legacy supporter-days purchase stack
(`PurchasesNotifier`, `PurchasesRepository`, purchase data sources) was
dissolved in ADR 0037 — the ads lane and `PurchasesLocalApi` (the
foundation's local receipt cache) remain.
