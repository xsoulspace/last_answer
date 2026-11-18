# Models management refactor — analysis & design (2026-11-14)

Owner ask: analyse how the Models interface is made, think critically about how it
should be refactored so providers and models are easy to **create, edit, observe,
stop** — with a hierarchy (providers first, then models) — informed by how
Zed, ZCode, opencode and pi do it.

This doc is analysis + design only. No code changes. Implementation waves at the
bottom await an owner go.

---

## 1. How it is made today

One monolith: `lib/shell/view_models.dart` (2012 lines) — view, view-model and
editor state machine in a single file. One scroll, four stacked concerns:

| Section | Widget | What it shows |
|---|---|---|
| header | `_DaemonHeader` (:117) | daemon live/pid, config path, scheduler state, **Restart / Stop** (daemon-level), Pro-gated `palette editor · PRO — See Plans` button |
| Generative rungs | `_RungSection`/`_RungRow` (:327/:380) | every declared cast entry: health dot, id, `provider/model`, chips `primary` / `local` / `→ ladder-next`, radio = `world.selectRung` (session "delegate via" override) |
| Decision rungs | same | non-generative cast entries |
| Providers (read lane) | `_ProviderSection`/`_ProviderRow`/`_ProviderDetail` (:897/:997/:1083) | per provider: merged worst-of health dot, id, base_url, transport chip, model count, **credential env NAME** (never a value); expand → model ids + context tier + read-only cast chips |
| Recent dispatches | `_TelemetrySection` (:526) | newest tool-loop row **per actor** (rounds, cache-hit %, stalled), top 8 |

Edit lane: `ProviderEditorDialog` (:1220) — a modal `Dialog` (720×620) opened only
through `ProGate(feature: TierFeature.paletteEditor)`. It keeps an in-memory deep
copy of the live palette wire document (`_candidate`) and mutates it with six verbs
(:1338-1515): `addProvider`, `editProvider` (id immutable while cast rows reference
it — refusal names them), `addModel` (writes `{'id': id}` only), `renameModel`
(cast rows follow the rename), `removeProvider` / `removeModel` (refuse while
referenced, naming the rows). Transport cycles a closed vocabulary
`openrouter | openai_compatible | system_one` (:1171). Landing lane:
dirty bar → **Propose** (`RealmChatService.proposePalette` → the harness's own
parser validates; receipt carries `beforeSha256` + diff + warnings +
`restartRequired`) → **Apply** (`applyPalette`, OWNER-only verb; a non-owner seat
renders the refusal's `recovery` verbatim) → `world.refresh()`. Cancel reverts.

Data sources (all read models, no LA-owned copy):
- palette document: parsed live `.xsoulspace/config.json` (`WorldStateService.palette`, `paletteConfigPath`);
- health: daemon's `~/.xsoulspace/palette_health.json` merged onto rungs (`_providerHealth` :878 = worst-of over the provider's rungs);
- telemetry: journal-projected per-actor dispatch rows (`telemetryByActor`);
- ladder/primary: fields of the cast entries themselves.

Harness schema consumed (read-only, `xsoulspace_agentic_host/palette_config.dart`):
`providers{id: {transport, base_url, credential_env, models[{id, max_tokens,
max_output_tokens, reasoning_effort, include_reasoning, capabilities{…}}]}}`,
`cast[{id, provider, model, role, primary?, …}]`. Literal credentials are refused
by the parser (`palette_literal_credential`); every cast model must be declared in
its provider's `models[]` (`palette_undeclared_model`).

## 2. Critical read — measured against create / edit / observe / stop

1. **The hierarchy is inverted.** The management unit everybody configures first —
   the provider (transport + endpoint + credential) — is the *third* section and a
   read-only afterthought; the binding layer (cast/rungs) leads. Owners arriving
   with "add ModelScope" land on a ladder of rung ids, not on providers.
2. **Two parallel representations of one document.** The read lane
   (`_ProviderSection`) and the editor's card list (`_editCard`) render the same
   palette twice with different widgets and different facts. Drift and double
   maintenance are structural, not accidental.
3. **The editor is a modal with a second-class model form.** `addModel` writes only
   `{'id': …}`; the harness schema's per-model fields (`max_tokens`,
   `max_output_tokens`, `reasoning_effort`, `include_reasoning`, `capabilities`)
   parse fine but are **uneditable** — a provider added in LA cannot declare a
   context tier or tool capability at all. There is no cast editing either: no
   ladder reorder, no primary change, no per-actor rebind (that lives in the actor
   info surface), so "manage models" stops at rename.
4. **Observe is per-actor, not per-model.** Telemetry rows key on the actor, so
   "which model is failing / what is its cache-hit rate" requires mental join.
   Provider health is a worst-of merge that hides which rung is sick. The ADR 0135
   cooldown state (a rung marked unusable *for this time*, auto-reviving) is
   invisible except as a detail string — the most operationally interesting fact
   in the system has no surface.
5. **Stop has one grain: the whole daemon.** Restart/Stop are process verbs. There
   is no per-dispatch cancel (the harness has none — `daemon_actor_loops.stop()`
   stops the whole loop set; `task op:cancel` cancels tasks, not dispatches) and no
   per-provider park. Parking collides with the CONFIG-INTENT law (never delete a
   row for a transient resource state) — the honest expression is cooldown
   visibility + ladder re-point, and neither exists in the UI.
6. **The gate is on the wrong verb.** `ProGate` wraps *opening the editor*, while
   the real authority gate (owner-only `palette_apply`) sits one layer down and
   already refuses with a named recovery. Stacked gates confuse: a non-Pro owner
   sees "PRO — See Plans" on a verb their seat authority would allow; a Pro
   non-owner pays for a dialog whose Apply refuses anyway. Reads and Propose are
   correctly free.
7. **Save + Restart is the only commit path**, and every prior-art tool except the
   harness's own daemon law reloads config live (pi reloads `models.json` when the
   picker opens; Zed watches settings). The restart requirement is honest today
   (cast changes bind at daemon boot) but the UI treats it as a footnote instead of
   a first-class pending state with a one-tap restart.

## 3. Prior art

| | config unit | models live | edit surface | bindings | observe | stop |
|---|---|---|---|---|---|---|
| **Zed** | `settings.json` → `language_models.<provider>` (`api_url`, key NEVER in file: env `<PROVIDER>_API_KEY` or provider settings UI) | `available_models[]` per provider: name, display_name, max_tokens, max_output_tokens, reasoning_effort, `capabilities{tools, images, parallel_tool_calls, prompt_cache_key, …}` | **dual**: "Add Provider" form in Agent Settings + full JSON | assistant-panel model picker, per conversation | none | none |
| **ZCode** | `~/.zcode/v2/provider_config.json`: `providerOrder[]` + per-provider `{providerName, templateId?, config{group, access{type, apiKey}, api{type, baseUrl}, personalModelIds[], modelOrder[]}}` | personal model list + explicit order per provider | full settings UI (the owner's reference point) | session model pick (`ListModels`: `providerId/modelId`, reasoning levels, disabled flag, current marker) | per-model disabled/health | n/a |
| **opencode** | `opencode.jsonc` → `providers.<id>{name, env[], package, settings{baseURL, apiKey?}}` | `models` map per provider: modelID, name, capabilities, cost, limit, headers, body, variants; reference `providerID/modelID` | **JSON only**; `/connect` for credentials | TUI `/models` picker, provider-scoped | none | none |
| **pi** | `models.json` → `providers.<name>{baseUrl, api, apiKey (literal \| $ENV \| !cmd), models[]}` | per model: reasoning, samplingParams(ByThinkingLevel), inputLimits, `promptCache{short,long}`; `modelOverrides` for builtins; baseUrl-only = proxy a builtin | **JSON only**, but **live reload** when `/model` opens | TUI `/model` search, Ctrl+S default, Ctrl+P cycle, `/scoped-models` | none | none |

Convergent laws across all four:
1. **Provider is the configuration unit** (transport + endpoint + credential);
   models nest under it. Nobody flattens bindings above the catalog.
2. **Credentials by reference** — env name, keychain or a settings UI; never inline
   in a shared/committed file (the harness parser is the strictest of the five:
   `palette_literal_credential` refuses literals outright).
3. **Bindings are a separate surface** from the catalog: a picker/command per
   conversation, never the config editor.
4. **Per-model options are rich** (capabilities, cost, limits, reasoning, cache
   lifetimes). LA's editor exposes zero of them.
5. **Config-first with an optional form** (Zed form + JSON; ZCode full UI;
   opencode/pi JSON-only). LA already has the right instinct — JSON view with
   named refusals (the Zed rule) — and should keep it as the advanced lane.
6. **Nobody observes or stops anything.** Health, cooldowns, dispatch ledgers and
   cancel verbs are absent everywhere. LA's resident daemon makes observe/stop a
   genuine product differentiator — the refactor must not copy their minimalism
   here, only their hierarchy.

## 4. Design

### 4.1 Information architecture — three lenses over ONE document

The Models view becomes a lens switcher (segmented control in the view header,
shadcn tabs) over the same palette + health + telemetry read models. Master-detail
inside each lens, using the shell's existing split law.

**Lens 1 — Catalog (default; the hierarchy the owner asked for).**
- Master: provider rows — health dot (per-provider, not worst-of-merged: show the
  sickest rung *named*), id, transport chip, endpoint, env NAME chip, model count,
  cooldown badge when any rung is in ADR 0135 cooldown (`unusable · revives in …`),
  chevron.
- Detail (split right or expand-in-place): the models **table** — one row per
  model with every schema field editable: id, max_tokens, max_output_tokens,
  reasoning_effort, include_reasoning, capabilities toggles; add model / remove
  model (refusal names referencing cast rows, as today); per-model cast chips
  ("used by: modelscope_qwen37plus, lfm").
- Provider verbs inline in the detail header: edit (transport / base_url /
  credential_env), remove (refuses with refs), and **no park** — parking is named
  as an honest absence until the harness grows an `enabled: false` semantics
  (surface_gaps ask §5); the cooldown badge is the truthful transient state.
- The editor dialog retires as the primary surface; its JSON view survives as an
  "Advanced · JSON" lane inside the Catalog detail (the Zed rule: raw document with
  named parser refusals), sharing ONE candidate state machine with the forms.

**Lens 2 — Bindings (today's rung sections, promoted and made editable).**
- Generative ladder as an ordered list (cast order = escalation order): drag or
  up/down verbs reorder the candidate's `cast[]`; `primary` is a settable mark
  (one radio, as today, but persisted through the same propose/apply lane instead
  of the session-only `selectRung`); each row keeps health + `→ next` chip.
- "Delegate via" (session `selectRung`) renders as an explicit session-override
  chip on the lens header, never confused with the persisted primary.
- Per-actor brainCast bindings link out to the actor info surface (which already
  edits them) — bindings lens shows "who rides this rung" as clickable chips.

**Lens 3 — Observe (LA's differentiator).**
- Dispatch ledger **keyed by model** (actor as a column, not the key): rounds,
  cache-hit %, stalls, at-time; filter chips per provider/model; today's
  per-actor view survives as a toggle.
- Health history per rung from `palette_health.json` statuses, with cooldown
  countdowns and the ADR 0135 named-skip events ("skipped: provider_429 ·
  revives 14:32").
- Daemon facts + Restart/Stop move here (they are observe/stop controls, not
  catalog chrome); a **restart-pending banner** appears whenever the landed
  palette fingerprint differs from the daemon's loaded one, with one-tap Restart.

### 4.2 Verb matrix (today → refactor, with the lane each rides)

| verb | today | refactor | lane |
|---|---|---|---|
| create provider | dialog, Pro-gated | Catalog detail, ungated draft | candidate → propose (free) |
| edit provider fields | dialog | Catalog detail inline | same |
| remove provider | dialog, refuses w/ refs | same, inline | same |
| park/disable provider | **absent** | named absence + cooldown badge | harness ask §5 |
| create model | id only | full field form | candidate → propose |
| edit model fields | **absent** (rename only) | table row edit | candidate → propose |
| remove model | dialog, refuses w/ refs | table row verb | same |
| set primary | session radio only | persisted mark | candidate → propose |
| reorder ladder | **absent** | Bindings lens order verbs | candidate → propose |
| rebind actor | actor info surface | link from Bindings lens | existing actor lane |
| delegate-via (session) | rung radio | header chip, labelled session-only | `selectRung` (local) |
| observe health | dots + worst-of merge | per-rung history + cooldowns | palette_health poll |
| observe dispatches | per-actor top 8 | per-model ledger + filters | journal projection |
| stop daemon | header buttons | Observe lens + pending banner | existing lifecycle verbs |
| stop a dispatch | **absent** | named absence on ledger rows | harness ask §5 |

### 4.3 Gate honesty (one gate, at the write)

Drop `ProGate` from *opening* the editor. Drafting and Propose stay free for every
seat (they already are, semantically); **Apply** remains gated by the harness's
owner-only `palette_apply`, whose refusal + recovery already render verbatim. The
Pro chip, if it stays anywhere, moves to a future cloud/paid feature — not onto a
config verb whose authority is settled one layer down. This is an owner decision
(§6 D1).

### 4.4 Code shape

- `lib/shell/models/` replaces the monolith:
  - `palette_candidate.dart` — a `ChangeNotifier` holding candidate doc, dirty
    fingerprint, receipt/apply outcome, and the six-plus verbs **as pure state
    transitions** (extracted verbatim from `_ProviderEditorDialogState` :1338-1575).
    Widget-free ⇒ unit-testable without pumping a dialog; the dialog's
    `debugLastCandidate` seam moves here.
  - `models_view.dart` — lens switcher + header + restart-pending banner.
  - `catalog_lens.dart`, `bindings_lens.dart`, `observe_lens.dart`.
  - `provider_form.dart`, `model_form.dart` (full schema fields),
    `json_lane.dart` (the retired dialog's raw-document view).
- `RealmChatService.proposePalette/applyPalette` unchanged (the participation-plane
  lane is correct); `WorldStateService` grows a per-model telemetry projection
  (keyed by `provider/model`, actor as payload) and a cooldown read from
  palette_health statuses.
- Widget-key contract: keep `models.provider.<id>`, `models.model.<p>.<m>`,
  `models.rung.<id>`, `models.receipt.*`, `models.refusal.*` stable; new keys
  `models.lens.<catalog|bindings|observe>`, `models.model.<p>.<m>.field.<f>`,
  `models.cooldown.<rung>`, `models.restartPending`. Test lane
  (`test/shell/models_editor_test.dart`) migrates onto the candidate model's unit
  tests plus per-lens widget tests.
- l10n: lens names, field labels, cooldown/restart-pending sentences — arb trio +
  four mirrors, hand-mirrored (never intl_utils).

## 5. Honest gaps → harness `surface_gaps.md` asks (file, never edit)

1. **Dispatch cancel verb** — per-dispatch stop for observe-lens ledger rows
   (today: daemon restart releases lanes; say so verbatim on the row).
2. **Provider park semantics** — an explicit `enabled: false` (or cooldown
   extension) that respects CONFIG-INTENT (row stays, revival named), so "stop
   using this provider" is a declaration, not a deletion.
3. **Palette hot-reload** — cast/provider changes currently bind at daemon boot;
   a reload verb would retire the restart-pending banner. (Optional; the banner is
   honest meanwhile.)

## 6. Owner decision points

- **D1 gate placement**: drop the Pro gate on the editor entry (recommended; the
  harness owner-only apply is the single real gate) vs keep Pro on Apply only vs
  status quo.
- **D2 lens IA**: three lenses (recommended) vs keep one scroll with providers
  promoted to the top.
- **D3 dialog fate**: retire the modal, keep its JSON view as the advanced lane
  (recommended) vs keep dialog + lenses both.
- **D4 bindings scope**: ladder reorder + primary in-app now (recommended; the
  candidate lane already validates them) vs defer to a later wave.

## 7. Waves (awaiting go; steward verifies + commits each, agents forbidden fvm)

- **L1** extraction only: `palette_candidate.dart` + folder split, keys and
  behavior frozen, dialog still the surface. Unit tests for every verb/refusal.
- **L2** Catalog lens master-detail + full model fields + JSON lane; dialog
  retires per D3; Pro gate per D1.
- **L3** Bindings lens (ladder order, primary, actor chips, session-override chip).
- **L4** Observe lens (per-model ledger, cooldowns, restart-pending banner) +
  surface_gaps asks filed.
Each wave: named tests green, `fvm flutter analyze` clean on touched files, l10n
7-file cross-check, live proof via flutter-native fmtk screenshots only.

---

## 8. Wave M (2026-11-15) — the lane-truth law + the Zed reasoning law

Owner review of the landed lenses named two untruths and one missing
configuration, both now fixed at the read-model layer:

### 8.1 `builtin` is NOT `local` (the lane-truth law)

The old chip law (`entry['builtin'] == true` → "local", and
`WorldRung.isLocal => builtin`) mislabelled every composition-root
builtin. The harness binding map (`ecsai.dart` `generationResourceKeys`,
`model_palette.dart` entry docs) resolves builtins to DIFFERENT lanes:
`lfm`/`qwen` = local MLX, `laya` = local System-One decision loopback,
`apple_foundation_afm` = Apple Foundation (on-device but Apple-specific),
`jev`/`open_router` = the HOSTED OpenRouter lane — `jev` is a remote
DeepSeek brain wearing a "local" chip. The fix:
`lib/coding_agent/realm_chat/palette_lanes.dart` mirrors the closed
builtin-name → lane-family map READ-ONLY (the same law as
`kTransportWireNames` mirroring `PaletteTransport`); the bindings lens
renders the family chip (`local` / `afm` / `open_router` / `builtin`) and
a subtitle sentence naming the lane; an UNKNOWN builtin name renders
`builtin` — no guessed lane. `WorldRung.isLocal` now means "on-device
family", hosted and unknown builtins are not local.

### 8.2 Reasoning is a lane capability (the Zed law)

Zed (crates/agent_ui `render_thinking_control`, settings
`LanguageModelSelection{enable_thinking, effort}`) hides reasoning
controls ENTIRELY when the model declares no thinking capability, titles
the tiers per provider family (Low/Medium/High/Extra High/Max), and keeps
separate selections per use case. LA's mirror:
`kReasoningEffortTiers` per transport (mirrored from the production
clients' `supportedReasoningEfforts`: openrouter = minimal…xhigh; the
openai_compatible chat-completions client and the local/AFM lanes declare
NONE today, so a declaration there refuses at dispatch as
`reasoning_effort_unsupported`) drives the catalog model form: a titled
tier picker (second tap clears the declaration) + the include toggle for
tier-carrying lanes; an honest absence note naming the transport
otherwise. Model rows chip the declared tier by title (`reasoning High ·
incl`). Per-use-case levels ("chat on low, delegation on high") have no
declarative lane in the harness today — filed as a surface_gaps ask
(2026-11-15) instead of faked in config.

### 8.3 Paid law: the arb trio was invalid JSON since 11-14

The 11-14 l10n insertion wrote `@key` description lines WITHOUT trailing
commas; arbs are JSON, and every key cross-check since was
substring-based, so the breakage survived. Repaired mechanically (comma
normalization) and the cross-check is now `json.load`-based. Law: the l10n
cross-check parses, never greps.

---

## 9. Wave N (2026-11-16) — actor equality, four lane classes, task honesty

The owner's six-point review of the live shell became five LA waves
(N1–N5, commits 2b79bca4 / ec0e9ba8 / fb32704f / b5744b55) plus three
harness asks (harness e2ed92a9). The laws it established:

1. **Actor equality.** A model-based actor is still an actor: roster
   adoption now takes `brainCast`-only rows (daemon-minted) with a
   synthesized `cast:` ref, so every actor is editable and DM-able;
   `registerActor` writes `brainCast` back for `cast:` brains so the
   daemon plane binds what LA edited (the black-hole law); Message and
   Remove (host retire verb first, roster tombstone second, one
   confirm, bounce verbatim) ride the actor surface and the people
   rows; minting lives where the people are.
2. **The owner's four lane classes** replace every picker vocabulary:
   remote providers / local server (loopback endpoints — the
   ollama-class lanes ride openai_compatible over 127.0.0.1 by the
   parser's own loopback allowance) / direct subscription (the ChatGPT
   plan; the Grok plan is a subscription lane closed until xAI issues a
   client id, ADR 0030; the qwen direct lane stays absent) / on-device services
   (AFM, laya, MLX — read-only facts, the composition root owns those
   bindings). `jev` reads remote; the word "builtin" never reaches the
   UI except as the unclassified fallback for a name the mirror does
   not know.
3. **The dynamic config editor (ZCode/ComfyUI law).** The model form is
   a settings-row list over the model map: typed controls from the
   per-transport schema mirror, an add-setting row (schema keys + free
   key), per-row remove, and unconsumed markers for keys no lane reads
   (the parser tolerates them; the UI names that instead of faking a
   control). The config list grows and differs per model and per
   provider — the editor follows the document, never a fixed field set.
4. **Reasoning is three layers, honestly split:** per-model declaration
   (dynamic editor), per-actor level (brainRef grammar `?reasoning=`,
   honored by the in-app brains — which previously DROPPED the declared
   effort entirely, a real wire bug this wave fixed), and the daemon
   lane (harness ask: per-actor generationOptions on realm_actors).
5. **Task honesty.** Queued is not running: rows tap open the durable
   detail (journal row verbatim + raw control events), carry the
   owner's Cancel through the queue's own verb, and a queued row under
   a sleeping daemon names why it waits. Boards cross-links the
   durable queue with its count instead of pretending the ADR 0140
   feed (landed, unwired) already projects it.
6. **One human, manageable.** Settings "Your profile" routes through
   the shell's ONE tab router to the human's actor surface; the actors
   pane lists the human labelled "you"; the avatar mark (glyph/emoji,
   the channel-icon law) applies to models, agents and the human
   alike.

### 9.1 Wave N5b addendum — retirement is world truth

Live proof caught the third adoption case: `akio-steward`'s durable row
carries neither brainRef nor brainCast AND is retired (2026-11-04
hygiene sweep). The owner law splits it: a brainless non-retired row is
adopted with an EMPTY brainRef (identity editable; the editor is how it
gets a brain; only its bot stays unbound), while a RETIRED row is never
re-adopted — the actor surface names the retirement verbatim
(`retiredAt · retireReason`) and hides Message/Remove, because verbs on
a retired actor would lie (commit b933d732).
