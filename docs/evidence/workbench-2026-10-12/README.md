# Editable workbench implementation — 2026-10-12

## Implemented scope

The article projection reads/writes existing DocumentRepository nodes. New metadata
nodes retain proposals, attributed history, evidence links, executable return/layout
configuration, bookmarks, and write-ahead recovery state. Existing document editing
reloads authoritative content when returning from the workbench.

Visible controls support block movement, section movement, splitting, evidence links,
proposal adoption/rejection/undo, a draggable restoration connection, reading-width
handles, selection, and recorded leave/reopen observations. Semantic workbench actions
enter the same handlers. Input origins distinguish surface input from semantic calls;
a UI event alone is not evidence that a physical human produced it.

DFP adds an interaction-session lifecycle. ecsly_flutter_scene adds consumer-claimed
drag callbacks that suppress camera orbit. Vosges adds an opt-in semantic gesture
selection adapter with pause/release cancellation. Its app-discovery/dispatch callback
still needs live installation; this is not physical gesture adoption.

## Evidence and current limits

Latest checkpoint: `background-final-regression.log` records 20 passing tests,
including six domain/recovery tests, three UI tests, the scoped harness-tool test,
action catalog parity and ordinary chat regressions. The earlier
`current-owner-ui-harness-checks.log` has ten passing workbench tests plus a failed
test-loader invocation caused by a nonexistent test path; it is not a green run.
`qualified-after-fixes.log` repeats the same 20 checks after scoped Dart fixes.
`latest-analysis.log` reports no errors or warnings and 15 style infos; analysis
is not a clean zero-issue gate.

Harness proposals have revision and current-task guards at staging. Investigations
reload saved ProjectModelDoc state. These are local contract checks, not evidence
that live independently participating actors completed tasks.

DFP interaction-session checks passed (2); scene camera/binder checks passed (10);
Vosges adapter/router checks passed (4) after the concurrent DFP compile errors
were fixed. Those do not establish physical gesture comfort or scene drag usability.
Their logs are `interaction-session-checks.log`, `scene-camera-binder-checks.log`
and `vosges-adapter-router-checks.log`. `checkpoint-source.sha256` fingerprints
the Last Answer workbench units at this checkpoint.

- `combined-checks-before-dfp-drift.log`: 17 checks passed at that source state,
  covering domain transformations/recovery, visible adoption + semantic undo,
  touch overflow, action catalog parity and existing chat regressions.
- `latest-owner-checks.log`: latest domain-only rerun; inspect its terminal result.
- `isolated-native-build.log`: separate candidate built and rendered using production
  WorkbenchScreen with a real filesystem repository and independent bundle identity.
- Computer captured and raised that candidate, including its native accessibility
  controls. After Antonio confirmed the candidate was on the current desktop,
  accessibility button clicks returned without a visible change; coordinate input
  failed with `noWindowsAvailable`. The native application menu did respond and
  was used to quit/relaunch only this isolated candidate. Subsequent binding calls
  returned `timeoutReached`, including after resetting the Computer connection.
  No completed visible article or behaviour journey follows from these attempts.
  The failure layer is unresolved; do not infer that Antonio's Mac is locked or
  that the candidate is on another desktop.
- Later UI/Vosges checks encountered concurrent DFP source drift: SetValueAction missing
  from the exhaustive synthesizer switch and a const exception constructor error.
  Retained failure in `vosges-blocked-by-dfp-drift.log`; not a pass.
- Harness orientation failed; a retry reported seat_admission_disabled. No bypass,
  second scheduler or self-declared canonical acceptance was introduced.
- Preserve the active meaning-task units and its ordinary-main native proof. Bounded
  Dart rewriting, shared claim/adoption wiring, complete actor collaboration,
  portfolio outcome/dependency grouping and 32/128/512 in-flight proof remain
  unfinished. The current portfolio is a basic project picker.
- `current-isolated-native-build.log` confirms the isolated candidate compiled
  after the authorization/resume changes and scoped fixes. That earlier checkpoint did not establish current-source interaction; the
  later background reports below do so for their bounded journeys.

## Resume / trial

### Background accessibility fix and qualified journeys

The initial runner found a window without product controls. Two lifecycle problems
were distinguished: the app forced Dart semantics before Flutter's native AX bridge
was enabled, and the automation attachment never requested the target's lazy native
accessibility tree. Removed the premature semantics handle. Explicit app attachment
now requests AXEnhancedUserInterface / AXManualAccessibility without activation;
attribute refusal codes remain available in the diagnostic receipt. A fresh tree,
not a setter acknowledgement, determines whether controls are usable.

The isolated macOS candidate uses a nonactivating accessory NSPanel so its window
remains available behind other applications and across Spaces. This is a testing
shell profile; the ordinary application's NSWindow was not changed. Background
semantic actions trigger a bounded warm-up frame for updated rendering. No global
pointer, keyboard injection or foreground activation was used in these journeys.

The latest independently rebuilt candidate passed resident background jobs after a
fresh launch, without running the diagnostic probe first:

- `navigation-background-current-report.json`: 21/21 steps; connection cancellation,
  stage, adopt, leave/reopen without restoration, return to writing, undo and restored
  connection. This caught and fixed an actual no-restoration inspector/focus bug.
- `article-background-current-report.json`: 14/14 steps; select a paragraph through
  its accessible object selector, move, reject, stage again, adopt and undo.
- `background-current-state.json`: independent filesystem read confirms rejected
  and undone proposals, exact original article restored and baseline behaviour.
- `background-final-regression.log`: 20 passing workbench, intent and chat checks.
- `background-driver-qualified-tests.log`: 55 passing native-driver checks.
- `background-runner-qualified-tests.log`: 10 passing runner checks.
- `background-registry-analysis.log`: targeted registry analysis has no issues.
- `reproducible-candidate-build.log`: successful isolated macOS build.
- `background-final-source.sha256`: current product/scaffold source fingerprints.

Earlier Computer timeouts, inaccessible-window jobs and the first fresh job missing
accessibility initialization remain failure evidence. They are superseded only for
these measured journeys. A mistyped runner-test directory also failed to load;
the correctly named runner_test.dart completed ten checks. No raw desktop screenshot
or system Recent Items menu is retained here. These synthetic native actions do not
establish physical human, Vosges or touch usability.

Rebuild the isolated shell with `fvm dart tool/workbench_candidate/build.dart`.
Launch its printed app path with `open -g -n <path>`. From
`dart_flutter_packages/pkgs/universal_automation_toolkit`, start the current source
runner with `dart run bin/universal_automation.dart --os --app
bundle=dev.xsoulspace.workbenchCandidate serve --http 0 --jobs-dir <directory>`.
Submit `background-navigation-plan.yaml` through automation_run_background and
poll automation_job. After navigation succeeds, submit background-article-plan.yaml.
The installed CLI/MCP catalog predates these source capabilities. Native job receipts
are automation evidence, not independently participating harness actors.

Production entry: Home → Workbench, or a normal document → Workbench. Create an
explicit sample article, select a paragraph, Inspect, Move down, inspect its candidate,
Adopt, then Undo. Select the project-opening connection, stage restoration changes,
Leave, Reopen, and inspect recorded observations. Dragging width only stages a proposal.

The isolated candidate's production entry source is
`lib/workbench/workbench_candidate_main.dart`; its filesystem samples are under its
own app's Application Support/LastAnswerWorkbenchCandidate directory. It does not
read the user's ordinary project store. This is a vertical implementation checkpoint,
not completion of ADR 0015 or the full requested product proof.
