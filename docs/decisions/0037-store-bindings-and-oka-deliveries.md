# 0037 — Store bindings, oka deliveries, and the dissolution of the legacy purchase stack

- **Status:** accepted (implemented)
- **Date:** 2026-11-21
- **Depends on:** oka ADR 0055 (buildable × pipeline × variant × channel),
  ADR 0035 (core dissolution), plan v5 4a (entitlement seam)

## Context

Store selection rode a `--dart-define=STORE=<enum name>` and a closed
`StoreType` enum in `lib/foundation/envs.dart` (with the `huawaiStore`
typo), switched at runtime inside `global_states_provider.dart` — so every
kernel compiled EVERY purchase backend, the switch had a RustStore-bug
fallback arm, and targeting a store oka/monetization never heard of meant
a package PR. At the same time the legacy supporter-days purchase stack
(`PurchasesNotifier`, `PurchasesRepository`, purchase data sources,
`PurchasesModel`) was dead scaffolding: nearly every method
commented out, its live surface reducible to `subscriptionsForBuild
.isNotEmpty`.

## Decision

**Store identity (oka ADR 0055 adopted):**

1. **One binding per kernel.** `lib/store/bindings/{rustore,google_play,
   apple,noop}.dart` are hand-typed `MonetizationStoreBinding`s (the
   `xsoulspace_monetization_foundation` extension of `oka_store`'s open
   `StoreBinding`: open `StoreKey` + nullable `purchaseProviderFactory`).
   `lib/entrypoints/main_store_<x>.dart` imports exactly ONE binding;
   `bootstrap(storeBinding: …)` threads it to `GlobalStatesProvider`.
   Only the imported backend compiles into the AOT kernel — the
   per-store-entrypoint mechanism (flutterfire-proven), never code-as-
   strings.
2. **Backend imports only in `lib/store/bindings/`.** Everyone else
   reads NAMED posture capabilities
   (`context.watch<MonetizationStoreBinding>().requiresStoreLogin /
   .isRuMarket` — `lib/store/store_posture.dart`) or the open
   `StoreKey` (no enum: a new store is a new key value, no PR). The
   key→posture mapping lives in exactly one file; UI files never
   compare store keys.
3. **Store ⊥ monetization direction.** monetization depends on oka
   (`oka_store`); oka never depends on monetization. The
   `InstallationTargetStore` closed enum is retired in favor of the same
   open key.
4. **Deliveries are the build surface.** `tool/oka_pipeline.dart`
   declares `Delivery`s (pipeline by const reference + variant: store
   key, per-store entrypoint, service overlays — `gms`, `hms-free` —
   + channel): `app-google-play` (aab), `app-rustore` (aab),
   `app-appgallery` (aab + hmsFree overlay; the channel prohibits `gms`
   — the old HuaweiBuildVariant law as composition-time legality),
   `app-apple-store` (macOS), `app-snap` (linux). justfile recipes are
   `oka run <delivery>`; `--dart-define=STORE=` lines are gone.
   iOS / Steam / itch / Epic / msix deliveries and the snap publish
   channel are roadmap rows — the contracts already express them.

**Identity end to end (2026-11-22 amendment — review wave):**

5. **The variant key reaches the binary.** oka bakes the delivery
   variant's store key as the `OKA_STORE` dart define (oka ADR-0055),
   and `bootstrap` verifies the booted binding against it — a real
   runtime check, not an assert (asserts vanish in release). The
   compile-time composition and the runtime binding can no longer
   silently disagree: `app-appgallery` / `app-snap` previously pointed
   at a vestigial `lib/main_prod.dart` that booted the noop binding
   while the variant claimed appgallery/snap.
6. **`bootstrap` requires the binding** (no default): a forgotten
   binding is an analyze error at the call site, never a silent
   no-purchase release build. `lib/main.dart` passes
   `noopStoreBinding` explicitly; `lib/main_prod.dart` (behaviorally
   identical to `main.dart` since the `Envs`/`StoreType` deletion) is
   deleted; `app-appgallery` / `app-snap` gained real entrypoints
   (`main_store_appgallery.dart` / `main_store_snap.dart` with
   key-correct `AppGalleryBinding` / `SnapBinding` — identity without a
   purchase backend, HMS IAP is a roadmap row).
7. **The isolation law is mechanical.** `tool/gates/
   store_binding_gate.dart` (justfile `store-gates`) fails any backend
   import outside `lib/store/bindings/`.

**Entitlement re-home (grammar compliance):** `pro_entitlement.dart` →
`lib/data_monetization/` (the state seam of the monetization concern);
`tier_gate.dart` → `lib/ui_paywall/` (UI). `lib/entitlement/` is
deleted; barrels are the public API.

**Legacy purchase stack dissolved:** `purchases_notifier.dart`,
`purchases_repository.dart`, `data_sources/{remote,purchases}.dart`,
`data_sources/local/purchases.dart`, `data_sources/interfaces/
purchases.dart` deleted; `PurchasesNotifier` consumers re-pointed
(settings' Pro entry reads `MonetizationProducts.subscriptionsForBuild
.isNotEmpty`; the supporter surface collapsed to the subscription-backed
view on every platform). The ads lane and `PurchasesLocalApi` stay.

## Consequences

- A store kernel contains exactly one purchase backend — provable by
  symbol search in the built binary.
- The RustStore fallback-arm bug class is gone (no runtime switch at
  all).
- New stores (Samsung, Amazon, a game portal) are a binding file + a
  delivery value — no package changes outside the app.
- Version duplication (pubspec × snapcraft × msix × oka_pipeline)
  remains a roadmap row (single version source).

## Verification

`fvm flutter analyze` 0 errors; entitlement/paywall tests green after the
re-home; kernel proofs (`oka run app-rustore` contains rustore symbols,
not google_apple) ride the normal release gates (blocked this session by
the ecsai_harness meaning-migration lane — attributed there).
