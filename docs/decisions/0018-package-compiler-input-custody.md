# ADR 0018 — Compile package candidates from captured inputs

- Status: Deferred; implementation retained, not active by default; native unqualified
- Date: 2026-10-19
- Parent: ADR 0016; harness ADR 0091; DFP ADR 0066
- North Star impact: applies; source and consent owners remain unchanged

## Current delivery boundary

The 2026-10-19 user correction defers semantic/materialization expansion and
Flutter self-edit qualification while cache work follows the existing autonomous
conventional product journey and its zoom/no-cut policy. `ProductWorkspaceTooling`
continues to select the pre-existing dependency-free
`ProductDartCandidateVerifier.instance.verifyCandidate` by default. Explicit
foreign web/compiler selections are preserved.

The headless CLI may explicitly select `verificationProfile: package_snapshot`
for the frozen real Flutter task. This uses the retained implementation through
existing product tooling injection; omission retains the existing default.
An ordinary `lib/main.dart` build may also explicitly select the same retained
profile with `--dart-define=LAST_ANSWER_CODING_VERIFICATION_PROFILE=package_snapshot`.
The shared `ProductWorkspaceTooling.forProfile` composes both seats. Omitting the
define keeps `existing`; unknown names refuse with `unknown_verification_profile`
and never fall back. This build opt-in does not promote the package verifier as
the default or qualify Flutter self-edit behavior. No consent, authority, source
policy, checker or execution deadline changes accompany this selection.

Open/status receipts name the headless selected profile, and autonomous web composition
cannot combine with it. Actual native compilation and source coverage still
require runtime evidence before any qualification claim.

The package-aware implementation below, its native freshness fences and local
contract controls remain available for explicit use and review. They are not adopted as
the default verifier, have no qualifying native two-pass Flutter runtime record,
and do not establish product readiness. Native builds and local checks alone
would not change that status. No deferred implementation supplies authority to
alter the current journey or its checker.

## Context

A real Last Answer coding task edits Flutter library files. The dependency-free
compiler profile cannot validate them: the native candidate contains only its
admitted source witness, and the VM platform does not provide Flutter libraries.
Running `flutter analyze` would require process forks outside the qualified
no-fork verifier. Running a check against live source does not check a candidate.

## Decision

Reuse the existing native candidate, compiler adapter, bounded process owner and
`macos_no_fork_candidate_v1` containment. Bundle the matching Flutter platform
with independently hashed compiler inputs. This package profile does not use the
legacy meaning experiment's lock or dependency seed.

The product captures its own configured package sources under existing private
candidate scratch and overlays exact candidate changes. A first, unaccepted
compiler pass discovers dependencies using only explicitly granted package
library roots. These compiler-only read grants come from the native current
generated package configuration within authorized project compilation; they do
not grant actors source-tool reads or writes outside their scope. Canonical
library escapes and library aliases refuse. Configuration and root identities
are pinned and rechecked; no whole-home grant or per-dependency prompt is added.
Its depfile identifies inputs to capture into the same scratch.
Only a second pass with snapshot-only source grants supplies compiler evidence.
Every changed present Dart source is an explicit compiler root, and the authoritative
depfile must confirm coverage. Metadata presence or content changes require a
separate resolution lane; deletion and absent-to-present changes cannot compile
against an old package configuration.
Missing inputs, unsupported metadata changes, capture limits or compilation
failures refuse explicitly. Neither pass executes candidate code.

The native extension optionally writes an exact versioned path/presence/change manifest
immediately before calling its trusted checker. The manifest is transient checker
input in declared scratch, inaccessible to source authoring. It records deletion
as well as creation/update; the product refuses malformed data, unknown staged
paths and presence mismatches. It is not serialized proposal authority.

`ConventionalCheck` may supply a trusted process-local synchronous input-freshness
callback. The issued native candidate retains it and checks it after consent and
before every source effect. It revalidates exact consumed original dependency
hashes, package configuration and canonical root identity. Exact staged source
paths remain guarded by the existing source witness; excluding them from the
callback permits a proposal's own first edit before its second edit. The native
owner checks its entire source witness before every effect, accounting for its
own preceding writes, so unchanged admitted inputs remain fenced too. An input
change refuses with `coding_verification_inputs_changed`.

Full check evidence, including failures, stays in the existing native candidate
artifact store. Actor-facing check projections are capped at 4,096 UTF-8 bytes;
omissions carry original byte/count metadata and a SHA-256 digest. Diagnostics
are explicitly clipped and counted. No parallel evidence store is added.

Saved artifacts retain diagnostic hashes, never callbacks. Adoption reconstructs
fresh preview/check state through the existing owner. Physical settlement remains
mandatory before candidate cleanup. The callback grants no writes, consent,
provider access or permission to replay an uncertain effect.

## Alternatives and consequences

Expanding the dependency-free entrypoint list cannot supply package resolution or
Flutter platform types. A live-source check can accept the wrong bytes. An
uncontained Flutter command would broaden execution authority. Copying every
resolved package would capture about 186 MB in this checkout; depfile capture
limits snapshot work to consumed inputs.

Two compiler passes increase verification latency. Snapshotting and repeated
hashing consume IO, while the declared caps can refuse larger workspaces.
Compiler-only success does not establish lints, behavior, final task acceptance,
UI readiness or generic command containment. Existing final task checks remain
unchanged. Source capture, stale/denied/failed controls and the real native
Preview/Apply/Undo/reapply journey still require measured qualification.
