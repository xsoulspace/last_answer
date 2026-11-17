# ADR 0029: Native image assets in Last Answer — notes attachments, media rendering, edit flows

- Status: accepted (implemented same day, 2026-11-16)
- Date: 2026-11-16
- Deciders: realm owner (Anton), seat session (ZCode/GLM)
- Scope: the note model, the note editor, the conversation surfaces,
  the backup/restore lane; companion to the harness program
- Companions: harness ADR 0142 (the record, the hands, the eyes) and
  the dfp ADR 0072 amendment 1 (the multipart lane). This ADR is
  Wave D of the analysis in
  `~/xs/ecsai_harness/docs/agent/native-image-assets.md` — the owner's
  "implement waves left" directive.

## Context

Waves A–C landed the harness side: the `asset-media v1` record
(metadata only, digest over bytes), the hands (`image_generate` /
`image_describe` behind the `ImageHands` seam), and the eyes (dfp
multipart + OpenRouter vision arrays + the image-token ledger). Last
Answer could not yet participate: notes had no attachment field, no
conversation surface rendered an image, the landed
`ImageGenerationService` had no UI consumer, and backup was a single
JSON file. The analysis scoped Wave D as four slices: notes assets
(LA-local), conversation rendering (driven by Wave A's header),
deterministic-first edit flows, and the workbench image layer — the
last explicitly owner-gated as its own design doc and NOT built here.

## Decision

Five laws, mirrored from the harness program:

1. **The file is the asset; the row is metadata.** `ProjectModelNote`
   gains an additive freezed `assets` list (`NoteAssetModel`: id, path,
   mime, alt, width, height, bytes, createdAt) — default-empty, so old
   JSON restores keep working unchanged. The BYTES live in sibling
   files under the app documents dir keyed by note id
   (`note-assets/<noteId>/<assetId>.<ext>`, the analysis's open item 3
   answered); `path` is documents-RELATIVE so backup zips, device
   moves and restores keep meaning. Pixels never enter any record.
2. **The sniff is the truth; the original never mutates.** `NoteAssetStore`
   imports by COPYING and sniffs the mime from magic bytes (the
   harness `media_meta` package — one sniffer, one owner). A
   non-media file refuses by name (`note_asset_not_media`), like the
   harness `ingest` verb. Every write goes through the
   `note-assets/` containment guard — a hand-edited row or crafted
   archive cannot escape the documents root.
3. **Every edit produces a NEW file.** Deterministic ops first
   (rotate / crop square / annotate — pure `image`-package code, no
   model, named refusals), generative second (I2I through the landed
   `ImageGenerationService` under the SHARED comparison budget wire).
   Strokes are DATA (`ImageStroke`) rendered as vector ink in the
   editor; only the explicit export bakes them into a new png. The
   original file and row stay untouched — the asset plane's
   generation law, mirrored in the app.
4. **One media card, honest in every state.** `MediaAssetCard` renders
   BOTH shapes: a harness beat whose text IS an `asset-media v1`
   header (parsed by the host's `AssetMediaProvenance.tryParse` — the
   grammar's owner; LA adds only the alt-body read) and a LA-local
   note attachment. Pixels render FROM THE FILE; an unresolvable or
   missing file shows the metadata placeholder (`mime · dims · kB ·
   file not resolved`) instead of pretending; alt text is the
   accessibility label. The world-chat beat row grows the media
   branch (relative paths render the placeholder there until a
   sandbox root is discoverable — honest, not silent); the agent-doc
   transcript resolves `file:` addresses against the doc's workspace
   root.
5. **Backup carries the files.** An asset-carrying backup is a ZIP
   (`PK` magic): `dbSave.json` (the exact legacy JSON) plus
   `assets/<relative path>` entries (`BackupZip` in core). Assetless
   backups keep the legacy JSON byte-identical; both stay loadable
   forever. Restore writes files through the app-side store sink
   (core stays path-free); rows whose files are missing keep the
   honest placeholder. Clipboard backup stays JSON (rows without
   files) — a device move uses the file lane.

The generate lane composes at CALL time (`composeForNotes`): the
OpenRouter images client under `ProductLocalPair.cloudBudget`, the
key from the environment — null honestly refuses when no key is
configured (desktop-first, matching the product-coding lane; a
settings-driven key is an owner product decision, out of scope here).

## Consequences

- A note can carry images: attach (gallery / camera on mobile /
  file picker on desktop), generate (T2I), and from an attached
  image: deterministic edits, annotate-with-export, and generative
  I2I ("make the sky stormy"). Every result appends a new asset row +
  file; removal commits the ROW first (the user's intent) and cleans
  the files best-effort after — the row must never wait on the file
  plane (proven by the project-action identity test, which runs
  without the path-provider channel). The note owns its
  attachments' lifecycle; an attachment-bearing note is not "empty"
  at pop.
- Conversation surfaces that meet an `asset-media v1` beat render the
  image card with alt semantics — the harness record becomes visible
  in the product without a single pixel entering any record.
- Backup/restore now round-trips attachments across devices.
- The l10n keys (17 × EN/IT/RU) and the camera usage strings
  (pairing + note photos) are part of the surface contract.

## Explicitly not built (owner-gated / follow-ups)

- **The workbench image layer** — the ecsly scene as host for an
  image component (layers compose images + vector ink + text): its
  own design doc when the owner picks it up, per the analysis.
- Sandbox-root discovery for world-chat media (relative `file:` paths
  render the placeholder there today).
- Per-social sharing of images (owner product decision).
- A vision describe pass filling `alt` automatically (spend follows
  intent — the harness `image_describe` + `op:ingest` loop is the
  actor-side path; the product surface is a later decision).

## Amendment — the conversation wave (2026-11-16, same day)

The DMs/channels slice landed on top of Wave D: the world chat
composer gains an image share (pick → copy into the realm world's
`assets/<threadId>/` dir → one `say` with a typed `media v1`
attachment — the harness vocabulary, validated host-side), the room
renders structured attachments as media cards, and the harness
dispatch resolves the addressed image into vision input for
vision-capable casts (harness ADR 0142 amendment 1). The v1 asset
home is world-local with ABSOLUTE paths (one device is the world);
the multi-device shared-root story is the named follow-up. The full
share pipeline is proven end-to-end by
`test/shell/world_chat_media_test.dart` (real store, real say, real
projection, real card render).

## Amendment 2 — the follow-ups (2026-11-17)

The three follow-ups landed in the harness packages (ADR 0142
amendment 2); LA's half of the conversation-media law moved with it:

- **The composer share path is WORLD-RELATIVE** (v1.1): the entry now
  carries `assets/<threadId>/<file>` — durable beats never embed
  device-fingered absolute paths. The share dir itself is unchanged
  (`<worldHome>/assets/<threadId>/`); the room resolves entry paths
  through the host's shared law (`resolveConversationMediaPath`),
  exposed here as `RealmWorld.worldHome` (the store dir's parent —
  the hermetic and production shapes agree). Old absolute records
  read forever; nothing migrates.
- `image_transform` (F5) and the durable per-actor image spend ledger
  landed harness-side — BOTH slices: attribution plus the OPT-IN
  ceiling (`realm_actor_image_budget_usd`; the reserve refuses
  `image_budget_exhausted` with the remaining named, refused reserves
  recorded; absent = unbounded, nothing seals). LA's half: the actor
  info tab renders the per-actor spend line
  (`actor.info.imageSpend`) folded from the realm store — absent rows
  render nothing. IT/RU trained.

## References

- Analysis: `~/xs/ecsai_harness/docs/agent/native-image-assets.md`
- Harness ADR 0142 — the record / hands / eyes (Waves A–C)
- dfp ADR 0072 amendment 1 — the `imageToText` multipart lane
- ADR 0025 (conversation threads on the kernel) — the beat renderers
- ADR 0023 (chat-first product) — the surfaces this renders into
