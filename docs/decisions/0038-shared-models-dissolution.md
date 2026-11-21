# 0038 — shared_models dissolution: server_contracts for the wire, domain folders for the rest

- **Status:** accepted (implemented)
- **Date:** 2026-11-21
- **Depends on:** ADR 0033 (deployables layout), ADR 0035 (core
  dissolution), ADR 0037 (store bindings / legacy purchase stack
  dissolution)

## Context

`packages/shared_models` was the last "shared bag" package: an account +
purchase leaf mixing four kinds of things — the ONLY models that actually
crossed the RPC boundary (`RemoteUserModel`, `UserModelId`,
`AdVideoLengthType`, `PurchaseType`), app-domain models that never did
(`EmojiModel`, `AdsStateModel`, `PaginatedPageRequestModel`,
`PurchasesModel`), foundation utilities (`createId`, `DateTimeX`,
`todayDate`, `StateInitializer`, callback typedefs), and dead legacy
purchase vocabulary (`IAPId`, `PurchasePaymentProvider`,
`PurchaseActionModel`, supporter-days state). After ADR 0037 dissolved
the legacy purchase stack, the bag had no reason to exist: the server
needed four models, the app owned the rest.

## Decision

**`packages/server_contracts`** (new, pure Dart, freezed) — the ONLY
models that cross the RPC boundary, named by what they ARE, not by where
they used to live:

- `RemoteUserModel` / `UserModelId` — the `getUser` payload (snake_case
  on the wire, unchanged).
- `AdVideoLengthType`, `PurchaseType` — the ad-reward vocabulary
  (`receiveAdVideoReward`); the server's `PurchaseType.videoAward.name`
  usage keeps the enum.

`generator.yaml` `extraClasses` points at
`package:server_contracts/server_contracts.dart:RemoteUserModel`
(`PurchaseActionModel` was never an RPC payload — dropped).

**The app-domain models move home (dissolution table):**

| shared_models piece | new home |
|---|---|
| `EmojiModel` | `lib/data_emoji/emoji_models.dart` |
| `AdsStateModel` | `lib/data_monetization/ads_models.dart` |
| `PaginatedPageRequestModel` | `lib/data_projects/paged_requests.dart` (plain class; the envelope's `toJson` codec was generated-but-unused — dropped) |
| `createId` | `lib/foundation/id_generator.dart` |
| `DateTimeX` / `todayDate` / `todayDateTime` | `lib/foundation/extensions/datetime.dart` |
| `StateInitializer` | `lib/foundation/state_initializer.dart` |
| `PurchasesModel` / `IAPId` / `PurchasePaymentProvider` / `PurchaseActionModel` / callback typedefs / unused extensions | dissolved with the legacy purchase stack (ADR 0037) — no consumers |

`common_imports.dart` drops the `shared_models` barrel export; consumers
import their own domain barrel or `server_contracts` directly.

**Server leg:** `deployables/server` + `packages/core_server_client`
swap the path dep to `server_contracts`; the unreachable-by-RPC
`PurchasesEndpointImpl` stubs (`recordPurchase`, `verifyNativeMobilePurchase`,
`getPurchases`, `mergeLocalPurchases`) are deleted;
`createPurchaseInfo` inlines the seed values (empty purchase state).
`serverpod generate` regenerates the client protocol against
`server_contracts`.

**`packages/shared_models` is deleted** (`git rm`); this ADR supersedes
the ADR 0035 note that kept it.

## Consequences

- The RPC contract is a four-model package with no app-state vocabulary —
  server and client can evolve their internals without dragging the app.
- No shared bag remains: every model lives in the domain that owns it
  (the folder grammar), and the app↔server boundary is explicit.
- `x-ver` serverpod CLI note: generation ran with `serverpod_cli 3.4.11`
  (`fvm dart pub global activate serverpod_cli 3.4.11`).

## Verification

`fvm flutter analyze` 0 errors; `flutter pub get` clean with
`git ls-files packages/shared_models` empty; regenerated
`core_server_client` + `deployables/server/lib/src/generated` trees grep
zero `shared_models`; `just gen` regenerates emoji/ads/server-contracts
parts.
