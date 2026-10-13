# Ordinary-launch experiment setup

The Home text entry `home.meaning_experiment` and published intent
`agent_meaning_experiment_create` invoke the same `openMeaningExperiment` path.
It verifies the bundled frozen fixture assets, prepares a new unique workspace
under application support, installs offline dependencies with the app-owned
runtime, persists the existing normal embedded agent document binding, and
opens it through `OpenedProjectNotifier.loadProject`. No launch define or manual
workspace binding is required. Existing notes and unregistered agent documents
receive no experiment tools.

The device-local registry validates canonical app-owned roots and the exact
frozen manifest marker before restoring fixture binding on document reopen.
Registration grants binding only; native issued previews, consent and inverse
recovery remain host-owned. New entry calls never reset existing roots or erase
journals. Preparation receipts expose manifest/runtime identity through the
create intent and `agent_doc_state.meaning.preparation`. Missing/unsupported
runtime is a named visible refusal; no ambient SDK/cache fallback is installed.

The bundled manifest is byte-identical to the upstream frozen criterion. Its
assets retain upstream SHA values; a separate delivery manifest pins the
packaged dependency lock. Focused asset/catalog checks passed five tests and
eight preparation source/test inputs analyzed without diagnostics. The earlier
analyzer failures are retained separately. These checks do not establish the
ordinary launch journey, native packaged execution or physical gesture
acceptance; those are independently owned criteria.

The previously documented `MEANING_GREETING_WORKSPACE` development launch path
is superseded by this entry. Ordinary-launch runtime/controller/view and
independent acceptance gates must complete before this flow is called ready.

The entry's primary failure message now uses plain EN/IT/RU wording for an
unavailable app build, unsupported device or retryable preparation failure.
The published create intent still returns the complete native code/detail
receipt. Focused entry/refusal test analysis is clean
(`ordinary-entry-refusal-analyzer.log`). Its isolated Flutter test did not
reach execution: native asset startup failed because `libmlx_native.dylib`
was absent during install-name adjustment, after the Flutter startup lock
wait (`ordinary-entry-refusal-test-tooling-failure.log`). No passing refusal
test is claimed from that run; it is included for a subsequent serialized
product gate.

Independent ordinary-main execution reproduced a 193 px Home toolbar overflow
in a 240 px column. The same experiment entry now occupies a separate full-width
text row beneath the toolbar; toolbar spacing contracts for narrow columns
without hiding or clipping the entry. Initial experiment admission now notifies
the surface at start/end, disables the root-owned view through its admissionBusy
property, and projects `meaning.busy = admissionBusy || controller.busy` with
the explicit admission detail. These source repairs await independent ordinary
main rerun; no screen focus/unlock operation was used.

After the native asset startup lane settled, the existing entry-refusal
headless test reran serially and passed (`ordinary-entry-refusal-rerun-green.log`).
Its selected entry/test hashes match before and after the run. This closes the
localized refusal-label check only; the earlier missing-MLX startup failure
receipt remains retained, and ordinary in-app/native journey claims are separate.
No source changes, runtime cache reset or app launch occurred in this rerun.
