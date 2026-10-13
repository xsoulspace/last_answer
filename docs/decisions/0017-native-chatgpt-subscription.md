# ADR 0017: Native ChatGPT authorization uses device-local credentials

Status: Accepted direction by operator; product/live qualification pending
Date: 2026-10-13
North Star impact: applies

The operator authorized the harness native-subscription plan in order. Compose
DFP `xsoulspace_inference_openai` for direct eligible SIWC/Responses inference.
Last Answer owns system-browser sign-in, protected account storage and resource
selection; the existing harness owns actor context, actions and acceptance.
Subscription entitlement does not grant access to a document/workspace or
authorize tool effects. Existing per-document hosted-transmission consent remains
required at dispatch; an OAuth scope is not that product consent.

`ChatGptCredentials` uses the existing `SecureValueStore` seam and atomically
replaces one protected registration bundle. It retains stable host identity,
distinct issued client/subject mappings, account-specific model choices and an
active-account pointer. Credentials never enter document config, CRDT/mesh state,
logs or UI projections. One composed auth owner serves that store and serializes
refresh/authorization/signout. Token removal retains registration identity, but
clears access/refresh/ID-token hints.

Direct native inference is selected for harness control of every decision;
Codex ACP remains a compatibility resource. No implicit API-key billing fallback
or another scheduler is introduced. Account selection never merges actors.

The software slice now includes the protected-store adapter, app-owned auth
controller, desktop account/model controls and matching debug/profile intents.
Native per-session clients compose the existing backend/handler; credentials
are shared only by one auth owner. Settings cancellation is distinct from task
cancellation, while account signout fences and settles all of its clients.
Document transmission consent includes the issued account registration, model
and workspace. Injected store, widget, cancellation and command-profile host
fixtures pass. Live browser consent and ordinary Keychain read/update have since
passed; production meaning-proposal native tasks remain pending. The protected registration bundle now implements the provider's durable mutation
fence. Pending mutations block reads/model selection and hide ID-token hints after
store/auth reconstruction. Explicit reauthorization or signout settles local
recovery; unknown remote outcomes remain uncertain. Actual process-kill/keychain
fault injection and persistent remote-cleanup receipts remain qualification work.

Sources: harness ADR 0092 and `docs/native_subscription_delivery.md`; DFP ADR 0067
links current official registration, account and preview contracts. Last Answer's
distribution/account eligibility must be tested rather than inferred from local
or noncommercial licensing.

The protected bundle also retains unresolved remote cleanup after local token
removal and account-controller reconstruction. Durable cancellation intent blocks
ordinary commit until explicit rollback, and account-state failures reload the
protected projection rather than keeping stale signed-in authority. Abrupt
process-kill, renewal and revocation qualification remain open.

Local macOS distribution currently uses ad-hoc signing. Its Data Protection
Keychain writes failed live with -34018 before browser launch. The subscription
store therefore explicitly uses the macOS login Keychain in the dedicated
`dev.xsoulspace.lastAnswer.chatgpt` service, with synchronization disabled. There
is no automatic error fallback, plaintext store or cross-domain token search.
Signed Data Protection distribution is a separately configured/qualified profile.

A user-completed OAuth registration, account-specific model discovery and one
direct gpt-6.1-sol request are now observed. The upstream Darwin plugin's failed
update delete/add branch motivated the bounded ordinary-writer repair below. Native
coding acceptance and later context/cache/mixed-actor delivery exits remain open.

Platform diagnosis: [Apple -34018 troubleshooting](https://developer.apple.com/forums/thread/114456)
and the installed flutter_secure_storage_darwin 0.3.2 source. No credential files
or token contents were inspected to diagnose it.


The application pins a narrow licensed Darwin plugin fork at
`third_party/flutter_secure_storage_darwin` (upstream 0.3.2, local build metadata
lastanswer.1). Ordinary single-item writes use SecItemUpdate and add only on a
definitive item-not-found result. Failed updates never delete the existing item;
racing creation returns duplicate-item without replay. Read-result flags from the
plugin's shared query are stripped before update/add. This preserves the protected
bundle/fence when replacement fails. No new auth owner or storage endpoint exists.

The upstream source license, file hashes, archive identity, local patch and removal
route are retained. Native injected controls and a synthetic OS login-Keychain
journey qualify this bounded ordinary-write path; Secure Enclave multi-item writes
and iOS runtime remain separate. Upstream replacement requires the same failure
preservation, rebuild and actual product qualification before dropping the override.

The final macOS debug app retained its account/model across a normal process
restart and successfully updated/read the protected bundle through the product
account action. Five injected native controls, one synthetic OS journey and 18
account-product regressions passed. These do not prove arbitrary crash recovery
or OS failures. The harness delivery evidence retains a non-PII live receipt.

Session startup exposes one shared completion future and marks ready only after
host startup completes. Backend mutations serialize through one configuration
lane. Work admission awaits configuration and session creation, then rechecks the
settings signature, host identity and workspace before dispatch. Initial widget
configuration begins after the first frame. Model consent, preparation and dispatch
share one desired-model resolver; consent for a previous model cannot authorize
a different transition model.

Product tooling cache entries have controller-owner lifetimes. Disposal drops
owned entries; late asynchronous preparation drops them again if its view has
unmounted. Existing live bindings and issued change journals remain intact. This
is lifecycle cleanup, not evidence for source/permission cache correctness.

Saved-route restoration and native actor reconstruction require separate live
receipts. A healthy account catalog or acknowledged navigation does not prove
that the addressed document's actor/view, workspace tools and obligations recovered.

Product debug projection retains at most 16 detached structural provider receipts.
Each read rebuilds nested count maps; clients and credentials are not retained by
those receipts. After granting exact document/model/workspace consent, the same
configuration lane publishes the native binding and clears preparation refusal;
the view checks mounted state before publishing UI changes.

Live native decoding required final item-done reconciliation: the subscription
stream delivered a final function item while its completed envelope had an empty
output array. The repaired DFP codec executed repo_etl and meaning_program through
the existing world. A fresh eight-start development actor reached native binding
discovery and source reads, then exhausted its cap without a preview. This is
connectivity/tool-path evidence, not native coding acceptance.

Two debug-process native accessibility-bridge crashes were retained separately.
Normal process rebuilding followed confirmed process/listener death; accessibility
was not disabled. The crash trigger still needs isolation.

Account/model cache identity is published only when its exact candidate binding
is adopted by the controller. A failed workspace preparation cannot relabel an
older account's still-adopted binding. Configuration signatures include consent
projection changes so an in-flight pre-consent preparation cannot swallow the
post-consent synchronization.
