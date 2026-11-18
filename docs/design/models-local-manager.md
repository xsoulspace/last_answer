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
