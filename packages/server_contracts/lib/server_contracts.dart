/// The server/client contract models (ADR 0038): the ONLY models that
/// cross the Last Answer RPC boundary — `RemoteUserModel` /
/// `UserModelId` (the `getUser` payload) and the ad-reward vocabulary
/// (`AdVideoLengthType`, `PurchaseType`).
///
/// Everything that used to live in `packages/shared_models` and never
/// crossed the wire moved into the app's domain folders (ADR 0038
/// dissolution table): `EmojiModel` → `lib/data_emoji`,
/// `AdsStateModel` → `lib/data_monetization`,
/// `PaginatedPageRequestModel` → `lib/data_projects`, foundation
/// utilities → `lib/foundation`. The supporter-days purchase models
/// dissolved with the legacy purchase stack (LA ADR 0037).
library;

export 'src/models.dart';
