# Local model manager — browse, install, delete (Unsloth-style)

Status: APPROVED direction (owner, 2026-11-18: "add ability to download and
install models like unsloth does — manage them as easy as possible").

## The laws

1. **The runtime never downloads silently** (the provisioning law,
   `ProvisionConstraints.requireUserConsent`): a download happens ONLY on
   an explicit user action in the manager, with the size named before
   consent. The runtime/inference paths stay never-download.
2. **The hub cache is the single store.** Installs land in the SAME
   `~/.cache/huggingface/hub/models--<org>--<name>/snapshots/<dir>/`
   layout the discovery scans — an installed model needs no second
   registry; it appears in the brain picker because discovery finds it.
3. **Delete only what the manager installed** (marker file
   `.installed-by-la-manager` in the model dir). A pre-existing cache
   entry (installed by a terminal, another tool) is never deletable from
   the UI.
4. **The memory incident floor is untouched** — installing is disk;
   loading stays gated (MlxLoadGate). The manager shows the floor state
   honestly (a model too big for the gate loads nothing until memory
   frees; the refusal names its inputs).

## The curated catalog (v1)

Static list in the mlx_native package (no network to browse; the entries
name MLX-converted, known-family text models):

| repo | label | params | quant | ~download |
|---|---|---|---|---|
| mlx-community/Qwen3-0.6B-4bit | Qwen3 0.6B | 0.6B | 4bit | ~0.4 GB |
| mlx-community/Qwen3.5-0.8B-4bit | Qwen3.5 0.8B | 0.8B | 4bit | ~0.7 GB |
| mlx-community/Qwen3-1.7B-4bit | Qwen3 1.7B | 1.7B | 4bit | ~1.0 GB |
| mlx-community/Qwen3-4B-4bit | Qwen3 4B | 4B | 4bit | ~2.3 GB |

(The dotted `Qwen3.5-*` family is already in the discovery law —
`_qwen3HubOrgs` includes the `Qwen` org; the 4bit convert is the
LOADABLE form of the raw checkpoint that hit the memory gate in the
2026-11-17 dogfood.) V2 candidates: live HF search, LFM2 family, MLX
downloads of user-pasted repo ids.

## The downloader

`mlx_native/lib/src/mlx_model_installer.dart`:

- Download list per repo: `config.json`, `tokenizer.json`,
  `tokenizer_config.json`, `vocab.json` + `merges.txt` (when present),
  `model.safetensors` OR `model.safetensors.index.json` + its shard
  files — resolved from `https://huggingface.co/<repo>/resolve/main/<file>`
  (404 = optional, skip honestly; a missing REQUIRED file fails the
  install with a named error).
- Destination: the hub-cache layout with a stable snapshot dir name
  (`snapshots/la-manager/` — the discovery only needs
  `snapshots/<any>/config.json`).
- Resume: partial `<file>.part` + HTTP Range; an interrupted install
  resumes, never restarts blindly.
- Progress: the existing `ProvisionProgress` shape
  (checking/downloading/loading + percent + bytes) — the seam in
  `xsoulspace_inference_core/inference_provisioning.dart` was defined
  for exactly this and awaits its first implementation.
- Consent: `userConsentGranted: true` only from the UI dialog that
  named the size; network-gate hook (`isNetworkAllowed`) stays
  available for a Wi-Fi-only policy.
- Delete: removes the model dir ONLY when the marker file
  `.installed-by-la-manager` exists in it.

## The UI (Models panel → Catalog lens, new "Local model catalog" section)

Under On-device services: one row per catalog entry — display name
(label + params + quant chips), approximate download size, state chip
(installed / not installed), and ONE verb: Install (consent dialog:
name + size + network) or Delete (manager-installed only; confirm).
During install the row shows the progress bar (phase + percent). After
install the variant appears in the actor creator's brain menu
automatically (the discovery picks it up; the 2026-11-17 label fix
renders `Qwen3.5 0.8B · local (MLX)` correctly).

Widget keys: `models.local.<refName>.row/.install/.delete/.progress` —
the agent UI contract.

## Out of scope (v1) — and what moved

Live HF search and user-pasted repo ids remain out of scope. MOVED IN
since: the LFM2.5 catalog entry (v3.1 — the `local:lfm` lane's own
provisioning). NEW OPEN CANDIDATE: the Laya checkpoint row (see v3.1 —
needs the cache-root decision). Still out: MLX convert-on-install,
daemon-side installs.

## v3 — the one-surface redesign (2026-11-18, owner-approved)

The owner's three requirements: ONE place from download to observation;
simple verbs (`download → start/stop` + optional config); realtime
health, Apple-storage manageable, AFM as the exempt edge case. Laws:

- **The bar IS the map** (`memory_budget_bar.dart`): each LOADED model
  owns a labeled accent segment carved out of the system's in-use
  chunk; a generating model's segment pulses; tap-through selects the
  row (`LocalModelsState.selectedRef`). Segment widths animate — a
  load sweeps in, an unload drains out (encode-only motion; scene
  graphics stay a phase-3 option). Height 12px; the loose-height
  ColoredBox collapse (a segment renders 0px tall = the invisible-bar
  class of bug) is named in the code and caught by a tap test.
- **One quiet line per model** (`catalog_lens.dart` `_localModelRow`):
  dot + STATUS WORD (generating… / ≈tok/s / Downloaded / Not
  downloaded), metadata `params · quant · size`, ONE primary verb
  (Download / Load / Unload) + the `⋯` overflow (Details, Delete).
  Rows sort loaded → downloaded → not installed. Below 640px the line
  stacks to two.
- **Fit at the verb**: the per-row fit chips are GONE. The machine
  verdict is said ONCE above the rows (`models.local.budget.noFit`,
  shown when every downloaded-but-unloaded entry misses); a row whose
  Load the arithmetic refuses renders the verb DISABLED with the quiet
  reason line (`models.local.<ref>.fitReason`) at the moment of intent.
  The math stays single-sourced from the gate's floor.
- **Realtime**: `LocalRuntimeLedger` (LA-side singleton) carries the
  per-cast generation runs — `_LocalCastBrain.generate` times its
  await (begin/end/fail; tokens are the ~4-chars/word estimate, the UI
  says ≈). `LocalModelsState.startBudgetPolling` re-senses the memory
  every 2s while the pane lives (no-op in the test lane).
- **The detail sheet** (`⋯ → Details`): disk + memory states, the
  SENSED size on disk (a real symlink-resolving walk of the snapshot
  dir — never the approximation), snapshot path, last generation
  (≈speed) and the last failure verbatim. `used-by` (which actors bind
  the cast) is the noted phase-3 follow-up.
- **Built-ins are a footer**: dot chips (Laya / LFM 2.5 / Apple
  Foundation AFM · always-on), the sentence on the tooltip — no
  lifecycle verbs; AFM visibly exempt.

Widget keys (v3 contract): `models.local.<ref>.row/.status`-less (the
word rides the row) `/.download/.load/.unload/.menu/.delete/.details/
.details.sheet/.fitReason/.progress`; bar `models.local.budget.bar/
.seg.system/.seg.model.<cast>/.seg.floor/.seg.available/.legend/
.legend.<cast>/.noFit/.unknown/.totalUnknown`. The `.disk/.mem/.fit`
chip keys are retired with the chips.

## v3.1 — the lfm lifecycle + the actionable verdict (2026-11-18, owner round 4)

The owner's round-4 asks: Laya/LFM should share the download lifecycle
(a fresh install needs it); the bar's "reserved" wording confused ("why
is there no place to start any model?"); phase 3 (used-by + motion).

- **The `local:lfm` cast joined the lifecycle.** Truth found: the LFM
  lane resolves `*LFM2.5-1.2B*` under the SAME hub cache
  (`resolveLfm2SnapshotDir`) — so the manager's install IS the lane's
  provisioning. Landed across the stack: the dylib's lfm2 engine
  gained `model_dir` + the one-engine-per-snapshot law (idempotent
  load, `mlx_native_lfm2_lookup`, existing unload; the Dart engine
  mirrors `adoptLoaded`/`isLoaded` and the lazy chat lane adopts
  first — no double weights); `MlxModelRuntime` gained the lfm
  load/unload/poll (same gate + in-flight map law);
  `PackageLocalModelRuntime` dispatches by family (`lfm2.5`); a
  `LiquidAI/LFM2.5-1.2B-Instruct-MLX-4bit` catalog entry makes the
  row a full Download/Load/Unload/Delete citizen; the resolver got
  the dangling-blob law (config + resolvable weights); the brain's
  `local:lfm` rung now lists only when the snapshot is discoverable
  (injectable probe; hermetic in tests). Live-proven:
  `tool/lfm25_runtime_probe.dart` — load → generate ("Paris…") →
  twin-load drives the SAME engine → unload → reload → sampled rung
  served → unload.
- **Laya's exemption is a PROVISIONING gap, not a nature (corrected
  2026-11-18 after the owner's challenge — the first v3.1 wording was
  WRONG):** the `laya` decision lane's brain IS an HF-downloaded
  model — the `laya-mlx` checkpoint (ModernBERT-large + decision
  head) at `~/.cache/xsoulspace/laya-mlx` (`LAYA_MODEL_DIR`
  override; `NativeLayaDecisionEngine.load`, fetched from HF
  `aac6fef/laya-mlx` — the runtime never downloads). The lane is
  SERVED out-of-app by the `laya-serve` sidecar
  (`LayaServeRuntime` attaches to its health endpoint; the in-app
  brain answers nothing while no sidecar runs), which is why the
  first draft mislabeled it "daemon-served" — the ECS daemon
  artifact (the harness's AOT `ecsaid` snapshot) is a different
  thing entirely. So a fresh install needs TWO provisions the app
  does not own yet: the checkpoint and a running sidecar. A Laya
  DISK-lifecycle row (Download/Delete for the checkpoint + the
  endpoint's health as the second stage) is the honest follow-up —
  it needs a decision: teach `NativeLayaDecisionEngine` to accept
  the hub-cache layout (the LFM law) or teach the installer a second
  cache root (`~/.cache/xsoulspace`). AFM stays exempt for real
  (Apple-provided, no download, no lifecycle).
- **The verdict is actionable.** "reserved floor" → "kept free
  (headroom)" — it is the load gate's incident floor (memory the
  gate refuses to touch, the 2026-11-14 crash law), said in human
  words. And when nothing fits, the line names the LEVER: "free 1.7
  GB more to run LFM 2.5 1.2B" (the downloaded entry closest to
  fitting, fewest missing MB).
- **used-by** (phase 3): the detail sheet names the actors whose
  brain binding matches the entry's casts (the roster read at open;
  `—` when nobody binds it).
- **Motion** (encode-only): the status word, the verb set and the fit
  reason crossfade (200 ms) on lifecycle changes; the bar already
  sweeps widths and pulses while generating.

## v3.2 — the memory honesty + the config-root option (2026-11-18, owner round 5)

- **The memory measure was not wrong in its formula — it was wrong in
  what it HID.** The formula (free + inactive + speculative + purgeable
  pages) is Apple's own "free percentage" basis (`memory_pressure`
  agrees within snapshot drift). What the bar hid: the machine can be
  DEEP in swap while "available" reads fine — inactive file cache
  reclaims at a cost, the compressor holds resident pages already
  squeezed, and swapped-out memory sits on disk outside every count.
  Landed: `MemoryFacts` now senses **compressor-occupied pages** and
  **swap used** (`vm.swapusage`); the bar discloses both when swap
  ≥ 256 MB (a `swapped to disk X GB` legend entry in danger ink + one
  caution line: "the machine is swapping — a load will add pressure");
  and the floor legend now shows the POLICY (4.0 GB) rather than
  `min(floor, available)` — the headroom is the gate's target, the
  shortfall belongs to the verdict line. The GATE stays floor-based
  (policy unchanged): making it pressure-aware is an owner decision.
- **The config-root option.** The models header showed
  `/Users/antonio/xs/ecsai_harness/.xsoulspace/config.json` — a dev
  checkout — because the daemon was spawned with `ECSAID_ROOT` pinned
  there and its authority row carries the root. Laws landed:
  `WorldStateService.configRootOverride` (persisted under
  `ecsai.configRootOverride`) LEADS the config candidates; the models
  header's path row gains an edit verb (`models.config.edit`) opening
  a dialog (empty = the defaults: the daemon's realm root, else the
  global `~/.xsoulspace`). Direction (roadmap): Last Answer should
  embed or download the ecsai runtime with its GLOBAL config home —
  never point into a development checkout; the env pin remains a dev
  tool. (Mobile/web integration rides that distribution story.)
- **The model-store dedupe (analysis).** One store already rules the
  text models: the HF hub cache is both the installer's target and
  every resolver's source (qwen discovery, lfm2 resolver, and now the
  laya resolver — `resolveModelDir` accepts a
  `models--*laya-mlx*` snapshot with `rl_agent_config.json` +
  weights, the lfm2 law mirrored), so a manager install and a
  pre-existing HF download are the SAME bytes — nothing duplicates.
  Remaining duplication vectors, named: (1) the raw-org checkpoints
  in the hub cache (`Qwen/Qwen3.5-0.8B`, `RikiyaT/...`) coexist with
  the mlx-community converts — the collision law prefers the convert;
  a "use the already-cached checkpoint" option is the v2 pasted-ids
  lane; (2) laya-mlx's historical home under `~/.cache/xsoulspace`
  predates the one-store law — the resolver now accepts both, no
  migration forced; (3) dangling snapshot dirs (the wiped-blobs
  Qwen3-0.6B) hold no bytes and discovery already refuses them.

## v3.3 — Activity-Monitor parity + the global-config law + the laya row (2026-11-19)

The owner's three verdicts drove this round: "the memory still incorrect
and has weird grey bar section which doesnt mean anything — and notice:
we have 16gb of ram", "we should always use only global config (local
config is preserved for overrides)", and "apply remaining fixes".

- **The memory measure, calibrated at last (v3.3).** The v3.2 basis
  (`free + inactive + speculative + purgeable`) read **587 MB available**
  on the owner's 16 GB machine where Activity Monitor showed **2.01 GB
  of reclaimable Cached Files** — the numbers were internally consistent
  but spoke a different language than the OS surface the owner
  cross-checks. Live calibration pinned the real identity
  (`vm_stat` → Activity Monitor, matched to the decimal):
  `Cached Files` = **file-backed pages**; `App Memory` = **anonymous
  pages**; `Compressed` = **pages occupied by compressor**; and
  `total = anonymous + wired + compressor + file-backed + free +
  speculative` (±1%). Landed in dfp `MemoryFacts`:
  `usedMegabytes` (anon+wired+compressor), `cachedMegabytes`
  (file-backed), `freeMegabytes` (free+spec), and the gate basis
  `availableMegabytes` = **cached + free** — what the OS can hand a new
  allocation by reclaiming the file cache, without squeezing running
  apps. A vm_stat without the modern rows falls back to the legacy
  composite (pinned in the dfp test with both recorded outputs).
- **The bar speaks Apple's categories (no unlabeled chunk).** The v3
  grey rest was the owner's "doesn't mean anything": the floor drew
  itself as a yellow SEGMENT of observed RAM when it is POLICY. The
  v3.3 bar is pure observation: **in use** (ink-quiet, LABELED — the
  working set with each loaded model carved out as its accent segment,
  unchanged tap-through + pulse), **reclaimable cache** (accent .25),
  **free** (accent .60) — every chunk has a legend entry, and the floor
  moved to the **policy line** under the bar: "load policy keeps 4.0 GB
  free — available for local loads X" (caution ink when X is 0). Swap
  + swap-note disclosures unchanged. The fit verdict rides the same
  new basis: on the owner's machine it now says 2.5 GB available,
  policy keeps 4.0 — honest against Activity Monitor, not 587 MB.
- **The global-config law (LA + ecsai).** The owner: always the global
  config; local configs are overrides. Three moves: (1) **data** — the
  `model_palette` migrated from the ecsai checkout's local config into
  the device-global `~/.xsoulspace/config.json` (both files .bak'd;
  the checkout keeps only checkout-scoped keys); (2) **LA** — the
  palette chain is now `[override, device-global]`: the daemon's
  authority row (`configurationRoot`, which dragged LA into the
  checkout) and the world-home ancestor walk-up are GONE from the
  default chain, `_refreshAuthority` deleted, and the palette editor's
  save fallback lands on the global file; (3) **ecsai** —
  `loadPaletteConfig`/`resolvePaletteWriteSite` read the workspace's
  OWN `.xsoulspace/config.json` (exact root), never an ancestor walk-up
  (how any project under a checkout silently adopted the checkout's
  palette); the authority row stays the last-resort deployment
  override in the daemon/seat-host fallback chains. The config-root
  edit verb (v3.2) remains the way a workspace-local config applies.
- **The laya row (disk-only lifecycle).** The decision brain joined
  the catalog: `aac6fef/laya-mlx` (label Laya, ModernBERT-L · fp16,
  804 MB sensed) as a **DISK-ONLY** row — Download/Delete provision the
  checkpoint the laya-serve sidecar (and the in-app decision engine)
  resolve; NO Load/Unload (the brain never occupies this app's engine —
  `PackageLocalModelRuntime` refuses the family, the row renders no
  memory verb, the noFit aggregate never names it, and the details
  sheet's memory row says "served by the laya-serve sidecar — no
  in-app residency"). The resolver now leads with the hub cache (the
  row's Delete IS the lane's un-provisioning), the legacy
  `~/.cache/xsoulspace/laya-mlx` stays as the pre-manager fallback.
  The details sheet also refreshes live now (ledger + actor roster
  merged listenable — the used-by row was read-once-at-open).
- **Out of scope, still named:** the pressure-aware gate (policy —
  owner decision), live HF search / pasted repo ids (v2 candidates
  lane), the ecsai-embedded distribution (global config home on
  mobile/web), and the flutter-scene hero (skipped per owner).

### v3.3b — the footer pruned + subtitles de-duplicated (2026-11-19, live)

The owner's screenshot verdicts on the live v3.3 surface: the footer still
chipped "Laya · Apple Foundation · LFM 2.5" although both models have
catalog rows ("it is a mistake — they are usual models as we defined"),
and every subtitle repeated its title's parameters ("Qwen3.5 0.8B —
0.8B · 4bit · 700 MB").

- **One place per model.** The v3 footer predates the catalog rows: its
  filter hardcoded only `rung.id != 'qwen'`, so the `lfm` and `laya`
  rungs rendered lane chips for models the section ALREADY carries —
  the model's name twice, the lane binding and its own brain listed as
  if they were two things. The filter is now the law
  (`kCatalogOwnedBuiltinRungs = {qwen, lfm, laya}`): a builtin rung
  whose brain the catalog owns renders NO chip. **AFM stays** — it has
  no lifecycle and no catalog row (the Apple edge case, owner design
  req 3), so the footer is exactly one quiet "always-on" chip.
- **Subtitles repeat nothing the title says.** The metadata line is
  `quant · size`; the param tag renders only when the title does not
  carry it (Laya keeps "ModernBERT-L · fp16 · 804 MB"; every Qwen/LFM
  row drops the duplicate). Hot-reload-verified live: "LFM 2.5 1.2B —
  4bit · 630 MB", "Qwen3.5 0.8B — 4bit · 700 MB".

## v4 — ONE Models surface (the merge: Catalog + Bindings + Observe → one ladder) — 2026-11-19

The owner's verdict on the three-tab surface: Bindings was "completely out
of sync with models" and should work as "user adds models from catalogue,
then manage its prioritisation"; Observe was "just additional information
about usable models" that belongs on the rows. The analysis held: the
three lenses read different domains (local checkpoints vs the palette's
escalation ladder vs per-cast health/telemetry) with different identities
(repoId+label vs cast id), so nothing could line up. All three are now ONE
surface:

- **The ladder is the models list** (the CatalogLens hosts it; the
  Bindings and Observe lenses are DELETED, the tab switcher is gone).
  One row per brain, in priority order — the position IS the policy,
  the sentences still say it ("thinks first" / "if X is down or stuck").
- **The alias law (the owner's critical annotation): a row speaks the
  MODEL it serves, never the cast alias.** A declared entry speaks its
  declared model; a local lane speaks the installed checkpoint's
  display label via `installedEntryForCast` (catalog order = the
  resolution order) — live: positions 8/9 read "LFM 2.5 1.2B" and
  "Qwen3.5 0.8B", and the fallback sentences name those labels too.
  The bare alias survives only as the honest empty-slot name
  ("Qwen" + Not downloaded + the download door) when nothing is
  installed, and the raw cast id stays the row's stable handle
  (subtitle/semantics) for agents and refs.
- **The Observe absorption** (`policy_components.dart`): health is a
  chip on the row (`ok · 22h` — dot already carried status), cache hit
  rate is a chip (`cache 47% · 2 r`, rounds-weighted), and tapping
  either opens the history expansion UNDER the row: the verbatim
  health verdict (code · detail · at) + the per-actor request rows
  with the escalation narrations. Unbound dispatches keep their own
  honest door at the ladder's foot. The daemon card became a slim
  header strip (live/pid · scheduler · Restart/Stop/Arm) above every
  lens — it is about the daemon, not a model.
- **Local lifecycle inline**: a local brain's row carries its active
  checkpoint's status word + ONE verb (Download / Load / Unload, the
  same `models.local.<ref>.*` keys) + the fit reason under a blocked
  Load; during a download the row IS the progress. The brain's OTHER
  checkpoints (the qwen family) live in the row's history expansion as
  full lifecycle rows — "add a model from the catalog" is one expansion
  away. The budget bar + machine verdict lead the section (they map the
  local rows). System lanes stay collapsed; laya's checkpoint download
  door rides the collapsed line.
- **Row tail scales as a whole** (the daemon-cluster law): sentence +
  chips live in a FittedBox — the two new chips could not overflow a
  crowded pane.
- Renames: section title "Brain policy" → "Models" with the one-line
  hint "Tried top-down — when one is down or stuck, the next takes
  over."; the Bindings/Observe tab labels and the observe-only strings
  are retired from l10n.

Known residue (named, not hidden): the qwen row's health chip can read
`not_downloaded` (the daemon's verdict about the cast's DEFAULT
snapshot — the dangling 0.6B) while the row title names the installed
Qwen3.5 0.8B; two true facts at different grain (cast health vs
checkpoint state), both visible, the expansion carries the detail.
Choosing which checkpoint a bare `local:qwen` binding resolves is the
discovery-order law today — a per-brain checkpoint picker is a later
wave.

### v4.1 — the catalog restored + the ladder manageable (2026-11-19, live)

The owner's verdict on v4: "you removed completely the old correct UI
where the user downloads/removes, starts/stops local models" and "the
models order is still unmanageable — no possible to add/remove models
(any: subscription, remote provider, local)". Both true, both fixed:

- **The Local models section is BACK** as its own visible block (bar +
  policy + every checkpoint as a full row with Download/Load/Unload +
  ⋯ Details/Delete + fit reasons). The v4 folding hid the provisioning
  behind chip-taps — a mistake; the ladder row's inline lifecycle stays
  (readiness at the priority position) but the CATALOG is the canonical
  provisioning surface again, budget bar leading.
- **The ladder is manageable**: "+ Add model" on the section header
  (provider picker over the declared providers + model id → the cast id
  slugs from the model) declares a generative cast at the ladder's foot
  (`PaletteCandidateModel.addCast` — unique-id + declared-provider
  refusals); every declared row gained a ⋯ **Remove from models**
  (`removeCast` — builtin lanes refuse by name: the composition root
  owns them). Both verbs ride the existing dirty bar (propose → apply →
  restart banner). Live-proven: the add dialog opened in the running
  app, cancelled clean.
- The honest boundary, still named: subscription lanes (chatgpt/grok)
  are runtime-plan rows, not palette casts — adding one to the ladder is
  a daemon capability gap, not a UI one; the direct-lane note in the
  Providers section says so.
