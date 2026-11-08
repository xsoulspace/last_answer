# Visual feedback loop — criticism and concrete speedups (2026-11-08)

Status: **analysis** (owner question: "how to make the visual feedback loop
faster with flutter mcp toolkit / harness"). Read-only exploration; no code
changed. Evidence base: files and gate artifacts read today —
`tool/gates/shell_harness_gate.dart`, `tool/smoke/chat_endless_smoke.dart`,
`justfile`, `docs/design/shell-redesign-rail-views-tabs-2026-11-05.md` §0,
`docs/history.md` (2026-10-01 entry), `docs/DESIGN.md` v2 header,
`lib/main.dart`, `test/shell/*`, `integration_test/*`,
`~/mcp/cline/mcp_flutter` (the `flutter_mcp_harness` + `mcp_toolkit` +
`fmtk` CLI checkout this repo pins), and the gate evidence dirs
`$TMPDIR/shell_hgate_evidence/`, `$TMPDIR/chat_smoke_evidence/`.
Measured facts are labelled **measured**; inferences are labelled
**hypothesis**.

---

## 1. The loop today, measured

Four legs, in the order a change travels:

**Leg 1 — edit → analyze.** `fvm flutter analyze` / `just fix`. Serialized by
the fvm single lock: exactly one fvm/flutter process at a time on this
machine (the concurrent-fvm deadlock law — the orchestrator owns those
invocations). **Measured** (context): any second agent that shells out to
fvm in parallel deadlocks the lane.

**Leg 2 — widget tests (headless, flutter_tester).** 160 `*_test.dart` files
under `test/` (**measured**: file count), including the shell suite
(`test/shell/app_shell_test.dart`, `rail_sem_probe_test.dart`,
`world_chat_*` family) and the coding-agent suite
(`test/coding_agent/*`). Hermetic by construction — e.g.
`test/shell/hermetic_world_state.dart` pins the doctor probe to a fixed map
and a nonexistent world home so no timer or machine state leaks in. This leg
is the fastest truth available and the only one that currently sees the rail
(§2 below).

**Leg 3 — live-app evidence.** Two disjoint routes with a hard capability
split (**measured**, release vs debug):

- *Debug/profile builds* (gate launches): `flutter_mcp_harness` owns
  build → launch → VM-service attach → drive. `lib/main.dart:12-19`
  initializes `MCPToolkitBinding`, so every debug instance exposes the
  `ext.mcp.toolkit.*` verbs (`semantic_snapshot`, `tap_widget`,
  `enter_text`, `press_key`, `scroll`, `drag`, `hover`, `wait_for`,
  `app_errors`, `inspect_widget_at_point`, `agent_catalog`/`agent_invoke` —
  `packages/core/lib/src/toolkit_extension_names.dart`) plus ~60 LA-registered
  runtime tools (`lib/mcp/app_mcp_tools.dart`, `doc_mcp_tools.dart`,
  `storage_mcp_tools.dart`).
- *The user's running app (release)*: no VM service, no CDP. The only live
  evidence is the macOS Accessibility tree via universal-automation
  (`automation_observe` with view/fields/subtreeOf; widget keys surface as
  AX names, e.g. `edge.world creature.la-world world live`,
  `worldchat.card`), AppleScript System Events for window geometry,
  CGWindowList metadata via Swift, and hand-written Swift CGEvent scripts
  for atomic activate+drag (universal-automation refuses global-event verbs
  while another app — Telegram — is frontmost). **Measured** (context).

**Leg 3b — screenshots.** The machine denies screen-recording:
CGWindowListCreateImage and window-targeted OS capture fail (**measured**,
context). BUT the toolkit's `flutter_layer` mode is engine-side raster —
`layer.addToScene(builder)` → `scene.toImage()` → PNG
(`mcp_toolkit/lib/src/services/screenshot_service.dart:100-125`) — which
needs **no screen-recording permission, no focus, no window position**
(`docs/design/shell-redesign-rail-views-tabs-2026-11-05.md` §0 table).
**Measured artifacts**: `$TMPDIR/shell_hgate_evidence/shell_gate_final.png`
(256 KB, Nov 6, gate `VERDICT: SHELL-HGATE PASS`) and SIX screenshots in
`$TMPDIR/chat_smoke_evidence/` dated **today** (Nov 8, 00:22 → 17:51,
100–247 KB each, `PASS evidence 6 screenshots ... (exit 0)` in
`steps.log`). So pixel truth of the LIVE (debug) app is not impossible —
it is already routine for gate launches. What is impossible is pixel truth
of the *release* app and of *native* surfaces (embedded webview, native
dialogs): `desktop_window` mode runs a ScreenCaptureKit Swift helper
(`.flutter_mcp/cache/macos_helper/macos_visual_capture_*.swift`) and that
is the permission trap.

**Leg 4 — design gate.** The interactive HTML mockup is the gate artifact
for the redesign (`docs/DESIGN.md` v2 header: owner approved the base
mockup 2026-11-08; "the mockup's threads/pick surfaces are the gate, not
the code"). Gen UI mockups cover *pre-implementation* visual review; legs
2–3 cover post-implementation.

Latency per leg (**measured where noted, else hypothesis**):

| Leg | Cycle time | Dominant failure modes (measured unless noted) |
|---|---|---|
| analyze | seconds–~1 min (hypothesis) | fvm single lock serialization |
| widget test | seconds per file, headless (hypothesis; suite-wide time not measured today) | hermetic overrides can't cross the real-HTTP/daemon boundary |
| debug build+launch (gate) | minutes; `--skip-build` reuses artifacts (`justfile gate-multiplayer`) | run3 today: `PASS launch` then `FAIL smoke TimeoutException: poll never passed: shell after first-run skip` (`steps-run3-bootfail.log`) — a first-run/boot race, not a harness failure |
| live drive + screenshot | seconds per verb; fmtk CLI subprocess per call (hypothesis) | named gaps below; DDC/DWDS flakiness on the web peer (`docs/history.md` 2026-10-01: DDC compiler died twice under ~2 s polling; cadence widened to 6 s) |
| release build | ~minutes (measured, context) | no VM service afterwards — the loop is blind on the artifact users actually run |

**Named live-toolkit gaps (measured, from today's `steps.log` and the gate
comments):**

1. `WARN rail-badge — rail subtree semantics-invisible live (named
   framework gap); widget gate + screenshot own it`. Same skip in the shell
   gate: `SKIP rail-strip-semantics — framework assembly gap live`;
   `shell_harness_gate.dart:20-23` names it a toolkit walker gap with
   evidence in commit `06017111`. The semantic_snapshot walker drops the
   rail column on live apps.
2. `WARN load-older — fmtk scroll cannot reach the reversed transcript live
   (named gap)` — the `scroll` verb cannot drive the reversed chat list;
   the affordance is widget-gated instead (`world_chat_tail_trigger_test`).
3. `shell_harness_gate.dart:164-167` (measured comment): the RAW
   `get_screenshots` extension answer "carried no usable images in gate
   launches" — the proven path is the fmtk CLI with `--save-images`
   writing `.mcp_screenshots/` into the output dir.
4. `docs/design/shell-redesign-…md` §0 (measured, 2026-11-05): with `mode`
   omitted the toolkit's AUTO policy prefers `desktop_window` on macOS when
   Screen Recording is granted — dragging in window position (x=-853 on a
   second display), focus races and permission preflights. Explicit
   `{"mode":"flutter_layer"}` is the loop mode; auto is only right for the
   once-per-phase native truth check (which this machine denies anyway).

---

## 2. Criticism — where the loop is slow or blind

**C1. The fastest pixel route exists but is not the default habit.** The
2026-11-05 analysis pass "lost most of its time to OS-level workarounds
(AppleScript clicks, window hunting across displays, screen-region
captures). None of it was necessary" (§0, measured). The orchestrator's
session today again ranked AX/AppleScript/CGEvent as the live-evidence
routes and concluded pixel verification is impossible — true for the
release app, false for any debug launch. The loop is slower than it must be
because the VM route lives in gate scripts instead of being the first
reflex of any visual iteration.

**C2. Semantic tree ≠ visual layout.** The AX/semantic route proves
presence, names and hierarchy; it cannot see overflow, clipping, wrong
color, mis-alignment, or a creature mark rendering as a blob. Today the
ONLY pixel-regression route in the headless loop would be golden tests —
and there are **zero** `matchesGoldenFile` uses in `test/` or `packages/`
(measured: grep found none). Creature marks (`CreatureMark` painter, live
per DESIGN.md v2 header), the chat stream, work cards and the strip can all
regress visually with every existing gate green.

**C3. The release/user app is a blind spot by design of the platform.** No
VM service in release ⇒ no fmtk, no flutter_layer raster, and OS capture is
permission-denied ⇒ AX-only. That is an irreducible floor for the *user's*
instance — but nothing forces visual iteration to happen against the
release instance. A debug twin (same world home, seeded state — hypothesis:
needs a check that two instances can share one world home safely; the
multiplayer gate already runs two real instances, so the substrate exists)
gets full VM-route coverage.

**C4. Live-semantic coverage holes push work back to widget tests.** The
rail subtree and the reversed transcript are invisible/undrivable live
(gaps 1–2 above), so §2.3-key assertions live only in
`rail_sem_probe_test.dart` and friends. That is honest, but it means the
live loop cannot verify the two most-iterated surfaces of the redesign
(rail, chat scroll) end-to-end, and every gate run prints SKIP/WARN rows
that normalize blindness.

**C5. Environment noise is real and partly self-inflicted.** Focus theft
(Telegram) breaks global-event verbs — universal-automation correctly
refuses, and the workaround is hand-written Swift CGEvent scripts per
session. The shell-redesign §0 already made the right law: "**no OS
automation (System Events / universal-automation) in the loop at all.** If
a step needs it, the app is missing a seam." The law is not yet enforced by
tooling — nothing fails a gate that reaches for AppleScript.

**C6. Boot/launch flake costs minutes per occurrence.** run3 today passed
launch and then timed out polling for the shell after first-run skip
(measured). With a full `flutter build macos --debug` ahead of every fresh
launch (harness README: own the build; `flutter run` is avoided as flaky
under automation), one boot race burns the whole build+launch budget.
`--skip-build` exists but the boot race itself is uninstrumented.

**C7. Golden-test caveats are real but bounded.** flutter_tester does not
auto-load app fonts; Inter is bundled at `packages/core/google_fonts/*.ttf`
(measured) and declared in `packages/core/lib/src/theme/material_theme.dart:54-57`,
so a one-time `FontLoader` in the test harness makes text deterministic.
Skia/Impeller raster differences across machines mean goldens must be
pinned to one host (this machine) or CI image — acceptable for a
single-owner repo; a hypothesis until the first goldens actually run.

**C8. Evidence is ephemeral.** Gate artifacts land in `$TMPDIR` and the
harness world sees only what someone broadcasts. An actor joining tomorrow
cannot see today's six screenshots or the FAIL row without reading tmpdirs
before the next reboot.

---

## 3. Concrete speedups, ranked by impact ÷ effort

### (b) FIRST — codify the VM-service route as THE visual loop. Impact: high. Effort: low.

Everything needed is installed and proven: `fmtk` at `~/.local/bin/fmtk`
(measured), `mcp_toolkit` bound in `lib/main.dart`, `flutter_layer`
captures with real bytes today. What is missing is a two-line reflex:

- `fmtk --vm-service-uri <uri> exec --name hot_reload_and_capture`
  (verb exists: `mcp_server_dart/lib/src/shared_core/commands/commands_catalog.dart:834`)
  — edit → hot reload → PNG in one call. This is the design-TDD loop the
  §0 table names; **hypothesis**: single-digit seconds per iteration.
- Explicit `{"mode":"flutter_layer"}` ALWAYS (never auto — C1/§0 finding).
- Screenshots via the CLI `--save-images` path, not the raw extension
  answer (measured gap 3).
- The app's own ~60 runtime MCP tools (`app_navigate`,
  `realm_chat_open_dm`, …) as state drivers instead of tap-choreography.

Deliverable: a `just loop-shot` style recipe + a short recipe doc (the §0
table promoted into `docs/`), so any agent's first visual move is the VM
route and OS automation stays the named-last resort.

### (a) SECOND — golden-file tests for the key surfaces. Impact: high. Effort: medium.

Zero goldens today (measured) against a live `CreatureMark` painter, chat
stream, work cards and strip — the exact surfaces the v2 redesign churns.
The deterministic flutter_tester host already runs 160 test files.
Prerequisites, all small: (1) a `FontLoader` bootstrap for bundled Inter +
NotoSans from `packages/core/google_fonts/`; (2) fixed test sizes (the
§ motion skill's ~320 px / normal / wide trio); (3) `just goldens` /
`just goldens-update` recipes wrapping
`fvm flutter test --update-goldens <dir>`; (4) one machine pins the rasters
(C7). Start with CreatureMark poses (blink/asleep/distressed/celebration —
pure `CustomPainter`, ideal golden subjects), `worldchat.card`, the work
card, and the strip at three widths. This converts "visual regression" from
a live-app expedition into a headless second-scale check — the single
biggest blindness removed per unit of effort.

### (d) Harness verdict: KEEP AND DEEPEN — not revive, not retire. Impact: high. Effort: low–medium.

`flutter_mcp_harness` is already the user-directed regular testing
mechanism (`docs/history.md` 2026-10-01, measured) with four live gates
(`justfile`: `gate-multiplayer`, `gate-shell`, `gate-chat`; plus
`world_inspector_harness_gate.dart`, `paired_device_gate.dart`) and honest
scenario reporting (today's run: PASS/WARN/FAIL/SKIP rows with named gaps).
The deepening work is the gap list, in order:

1. **Rail walker gap** — file/refresh the upstream issue against
   `~/mcp/cline/mcp_flutter` with commit `06017111` evidence; until fixed,
   keep the widget-gate ownership note (already in the gate header) and
   consider an LA-side seam fix: wrap rail rows in `Semantics` so BOTH the
   AX route and the toolkit walker see them (D2/Phase-2 direction — the
   shell-redesign doc already legislates this).
2. **Reversed-list scroll gap** — same treatment; the widget gate owns
   `worldchat.loadOlder` meanwhile (measured WARN row).
3. **Boot-race instrumentation** — the run3 timeout deserves a named log
   line at the first-run-skip → shell-ready transition so the next failure
   self-classifies (the smoke already dumps 4000 lines of child stdout via
   LogTap — the answer is usually in there, per its own comment).

### (c) integration_test on macOS as the physical-check replacement. Impact: medium. Effort: medium.

The lane exists and runs real on-device (`integration_test/coding_agent_afm_e2e_test.dart`:
`flutter test integration_test -d macos`, runtime-gated, honest skips).
Adding 2–3 physical scenarios — traffic-light zone interaction (the
"title-bar-is-gone lights zone", DESIGN v2 header), pane-seam drag via
`WidgetController`/`tester.drag`, ⌘K palette keyboard loop — replaces the
Swift CGEvent activate+drag scripts with in-process driving: no focus
thief, no frontmost-app refusal, reproducible in the fvm lane the
orchestrator already owns. The toolkit also has `drag`/`swipe`/`hover`
verbs for the live-debug variant of the same checks.

### (e) universal-automation as the AX leg — KEEP, demote, document. Impact: medium. Effort: low.

It remains the ONLY live-evidence route for the release/user app (C3) and a
useful cross-check on debug builds (AX names = widget keys, e.g.
`worldchat.card` — measured context). Keep it standard for: release-app
smoke, window-geometry truth (CGWindowList metadata), and the
accessibility-law checks DESIGN.md §Accessibility demands. Document the
Swift CGEvent activate+drag fallback as a versioned recipe (one file under
`tool/`, not per-session improvisation) with its trigger condition named:
"global-event verb refused while another app is frontmost AND the check
cannot move to integration_test." Per C5, its use inside the iteration
loop stays a defect signal, not a habit.

### (f) Harness-world integration of visual evidence. Impact: medium. Effort: low–medium.

Today evidence dies in `$TMPDIR` (C8). Cheap fixes with the existing world
surface: (1) gates already write `steps.log` + PNGs — copy the evidence dir
into a repo-ignored but durable location (e.g. `build/visual_evidence/<gate>/<date>/`)
as the last scenario step; (2) broadcast one beat per gate run
(`agent_participation {op:'message', broadcast:true}`) citing the VERDICT
row and evidence path, so any seated actor can see the visual state without
tmpdir archaeology; (3) keep the acceptance ledger row in
`docs/evidence/current-status.mdx` per the stewardship protocol; (4) for
design-gate moments (mockup approvals like today's), a `task` with the
screenshot paths as the artifact makes visual acceptance attributable
instead of conversational. **Hypothesis**: images themselves stay out of
the world journal (paths + hashes are enough); beat text is the projection.

---

## 4. Named minimal build order

Sized for delegation waves (each item independently mergeable, ordered by
what the next item needs):

1. **VM-loop recipe + justfile wrapper** — `just shot` / `just reload-shot`
   around fmtk with explicit `flutter_layer` + `--save-images` + pinned
   `--vm-service-uri`; recipe doc promoting shell-redesign §0's table and
   the "no OS automation in the loop" law into `docs/`.
   *Unlocks: second-scale edit→pixel iteration on any debug launch; kills
   the C1 habit problem for every future agent.* (1 wave, small)
2. **Golden bootstrap** — FontLoader for `packages/core/google_fonts/`
   Inter/NotoSans + first goldens: CreatureMark four poses,
   `worldchat.card`, work card, strip × three widths + `just goldens[-update]`.
   *Unlocks: the only headless pixel-regression gate (C2); makes visual
   churn in the v2 redesign safe at test speed.* (1 wave, medium)
3. **Semantics seam repair** — `Semantics` wrappers on rail rows / strip
   controls per D2-Phase-2, verified by `rail_sem_probe_test.dart` AND a
   live `semantic_snapshot` row in `gate-shell` (turning today's SKIP into
   PASS); upstream walker-gap report to mcp_flutter with `06017111`
   evidence. *Unlocks: live-loop coverage of the rail (C4); AX route sees
   the redesign's most-iterated surface.* (1 wave, medium)
4. **Physical scenarios in integration_test** — lights zone, seam drag,
   palette keyboard loop on `-d macos`; CGEvent fallback recipe filed under
   `tool/` with its named trigger. *Unlocks: drag/physical checks without
   focus theft or Swift improvisation (C5, item c/e).* (1 wave, small–medium)
5. **Durable visual evidence** — gate-final copy of evidence dirs out of
   `$TMPDIR`, one broadcast beat per gate run, ledger row in
   `docs/evidence/current-status.mdx`. *Unlocks: multi-actor participation
   in the design loop; visual acceptance becomes attributable world data
   (C8, item f).* (half wave, small)
6. **(Optional, after 1–5) Debug-twin smoke of production state** — launch
   a debug instance against the user's current world home (safety check
   first: the multiplayer gate proves two-instance substrate, but world-home
   sharing is unverified — hypothesis) and run `smoke-chat` against it.
   *Unlocks: VM-route evidence over real user state, closing most of the
   release blind spot (C3) without touching release capability.* (1 wave,
   medium; gate on the safety check)

What each item deliberately does NOT do: no new daemon, no second world, no
catalog app (flutter-design-loop skill law); no edits to ecsai_harness or
ecsly — toolkit gaps go upstream to mcp_flutter as named issues, LA-side
workarounds stay in LA gates and docs.

---

### One-paragraph answer to the owner

The loop is not missing capability — it is missing reflex. The pixel route
(`fmtk` + `flutter_layer`, engine-side raster, no screen-recording
permission) already produced six real screenshots of the live app today and
a passing shell-gate capture on Nov 6; the hot_reload_and_capture verb
makes edit→pixel a single call. The two genuine blind spots are (1) no
golden tests anywhere, so nothing headless catches a visual regression, and
(2) the release app, which is platform-blind by design and best served by
keeping universal-automation's AX leg plus a debug twin rather than by
fighting the permission trap. Fix the habit (recipes + justfile), add the
goldens, repair the rail/reversed-list semantics seams so the live loop
stops printing WARN, move physical checks into integration_test, and make
gate evidence durable world data. Items 1–5 are five small-to-medium waves;
none requires touching the fvm lock law or the harness repos.
