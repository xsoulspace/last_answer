# ADR 0021 — Generic project operations and browser session ownership

- Status: Accepted (lane B scope; the browser surface stays with the
  product lane that owns it)
- Date: 2026-10-21
- North Star impact: `applies` — a coding workspace becomes usable for
  ordinary projects, not only for the one language the product happens to
  ship a compiler for. It does not change the writable-document law
  ([ADR 0012](0012-writable-agent-doc-and-acp-client-first.md)) or the
  one-surface law ([ADR 0019](0019-two-products-one-surface.md)).
- Builds on: [0016](0016-reversible-code-candidates-over-native-owners.md)
  (the owner materializes, the candidate is reversible), [0018](0018-package-compiler-input-custody.md)
  (candidate input custody), [0019](0019-two-products-one-surface.md) (one
  surface, one world), [0022](0022-general-browser-window.md) (the general
  browser window) and oka's process lifecycle (ADR-0018 leases: identity
  over pid, ownership before signalling, report-never-guess).

## Context

Two product seams assume Dart, and only Dart.

1. `ProductWorkspaceTooling` defaults to a dependency-free Dart compiler
   check. It is a *good* default for the product's own journey, but it is
   written as "the checker is a Dart compiler", not "the checker is a
   declared project operation".
2. `ProductWebPreview` copies the workspace's `.dart` sources into a
   temporary candidate, compiles them to JavaScript and serves the result
   from its own HTTP server. It is a *renderer* for one language, and it
   cannot render a project the product does not compile.

An ordinary coding project — a React app, a Node service, a Rust crate — has
commands already declared by the project itself (`package.json` scripts, a
Makefile, a `pubspec.yaml`). The product was re-deriving those commands for
one ecosystem instead of *reading* them, and the preview surface was a
compiler wearing a browser's clothes.

There is a second, sharper problem. "Preview" had quietly become "serve my
own compiled artifact on my own port". A preview that owns a server is a
process with an owner; the browser window that renders it is a different
thing with a different owner. Conflating them makes the teardown law
unanswerable: who may kill the process on the port, and who may not?

## Decision

The shared implementation is owned by `oka_core/project_operations.dart`
(Oka ADR 0050). Last Answer retains compatibility exports and product wiring.
Language examples are profiles, not renderer implementations.

### 1. Project operations are declared data

A `ProjectOperationProfile` publishes *operations* — `check`, `build`,
`serve` — each with:

* an exact executable and argument list (argv), never a command string;
* an explicit working-directory **reference** (`candidate`, `project`, or an
  absolute `external` path);
* explicit environment overrides;
* an optional declared readiness probe and endpoint.

Nothing parses a shell string, nothing guesses a command from a file name,
and nothing asks a shell to interpret a command line. Dart/Flutter and
React/npm are *fixtures* of the same contract; the controller has no
per-language branch.

### 2. The controller runs declared operations and reports honestly

`ProjectOperationController` runs one declared operation through oka's
bounded run (the same seam `SystemProcessRunner` wraps) and captures the
exit code, the bounded stdout/stderr, the spawn or deadline error, the
duration, and whether the work physically settled. A deadline stops the
discovered process tree instead of abandoning the child; an unverified
teardown is reported as unsettled, never as success.

### 3. A browser session owns a *process*, not a browser

`ProjectBrowserSession` is the preview contract after this ADR:

* **navigation / attachment** — the session exposes a URL a browser window
  can navigate to, and can attach to a target that is already served;
* **ownership** — a target this session spawned is `owned` and is stopped
  through oka's identity-gated tree stop, after which its lease record is
  dropped; a target somebody else serves is `borrowed` and is **never**
  signalled;
* **last known good** — a failed attach keeps the last working target, so a
  broken change shows the previous working thing instead of a blank page.

The session does not own the browser window. [ADR 0022](0022-general-browser-window.md)
draws the same line from the other side: the embedded window never starts,
stops or compiles anything, and "a server's lifecycle belongs to whoever
owns the server". This session is that owner, and the window consumes the
session's URL. The ownership value the session exposes is what the window
lane applies to its own window.

### 4. The product's own preview is retired as a *language* preview

`ProductWebPreview` keeps its current behaviour for the product's internal
task-board journey. It is **not** extended with a React or any other
renderer: a preview that compiles one language is a compiler, and the
browser surface replaces it with a general window that can render any URL or
browser-supported content. The parent lane owns that surface change; this
ADR owns the contract it consumes.

### 5. The candidate verification contract is not bent to fit

The generic `check` operation is **not** wired into
`ConventionalChangeToolExtension.verifyCandidate`. The host's candidate is a
*partial* tree (the changed files plus the declared dependency paths), and
an ordinary project's build needs the whole project: `npm run build` in a
candidate without `src/` and without `node_modules` fails for reasons that
have nothing to do with the change under review. Verifying the live project
instead would report a check that never saw the candidate — a false green.
The profile is therefore exposed next to the binding, and the surface lane
decides when a whole-project check is honest.

External package roots are *referenced*, never copied: a candidate may link
an external `node_modules` rather than duplicate it.

### 6. A project declares its operations; the product reads them

A project publishes its own commands in `.oka/project_operations.json`, at the
project root. The file carries the *evidence shape* of a profile — the JSON a
`ProjectOperationProfile.toJson()` produces — and `oka_core`'s strict codec
(oka ADR 0050) is the only decoder. A refused declaration is a visible
validation error, never a repaired guess: the product does not infer a command
from a file name, does not auto-detect a stack, and does not fall back to a
shipped fixture when the project declared nothing. Reading the declaration
starts nothing.

The product surface is a *project operations* panel, not a second preview. It
shows the declared operations and runs them only when a person clicks. The
check operation is labelled **"Working tree check"**: it runs the project's own
command against the owner project root, so it is never evidence about a
candidate and the panel never presents it as acceptance. The candidate
verification contract of §5 stays untouched.

The serve operation is owned by oka's `ProjectBrowserSession`. The panel keeps
one session, opens the general browser at the URL that session exposes, and
stops only a process the session owns; a borrowed target is never signalled.
The panel is a widget the parent lane mounts — this lane does not touch
`ProductAutonomy`, `ProductWebPreview`, the task-board authority or the agent
doc surface.

## Consequences

- One contract for ordinary projects. Adding a language is a fixture, not a
  branch in the controller.
- The teardown law becomes answerable: the session says who owns the
  process, and a borrowed target is never killed.
- A failed change keeps the last working preview instead of blanking it.
- The product's Dart compiler default is unchanged: the generic profile is
  opt-in, and the candidate verification contract is untouched.
- Lease records live in a directory the caller owns (the app's support
  directory), not inside a user's project tree. The product does not write
  `.oka_cache/` into somebody else's repository.

## Non-claims

- **No ordinary-project acceptance is claimed.** The tests below are unit
  and process tests over real temporary directories. They are not a live app
  run, and they close no PLAN.md acceptance gate.
- **No UI acceptance is claimed.** No product surface was changed by this
  ADR; the browser window is [ADR 0022](0022-general-browser-window.md)'s
  work, and the launcher that connects a session's URL to that window is
  the parent lane's.
- **No claim that the profiles are complete.** The shipped Dart/Flutter and
  React/npm profiles are fixtures of the contract, not a survey of every
  ecosystem, and the React profile is explicitly a fixture rather than a
  product promise.
- **No claim that a project-scoped check validates a candidate.** That is
  the reason §5 refuses the wiring.
- **No new storage, process manager or shell runner** was introduced: the
  lease registry, the bounded run and the tree stop are oka's, reused.

## Gaps this lane could not close

- **`oka_core` was a dev dependency of the app package.** (Closed after this
  ADR was written: `oka_core` is now a regular dependency of the app, so the
  `depend_on_referenced_packages` workaround this lane's first cut needed is
  gone. The two library files that use oka's bounded run, lease registry and
  tree stop no longer carry a targeted ignore.)
- **The panel is not mounted yet.** The widget (`ProjectOperationsWidget`)
  and its session exist and are exercised by focused tests, but this lane
  does not touch `AgentDocSurface`: the parent lane mounts the panel. Until
  it is mounted, no product surface reaches a declared operation.
- **`ProductWebPreview` was not modified.** The correction replaced the
  preview contract with a general browser window; retrofitting the
  Dart-serving preview with a URL/ownership seam would keep a
  language-specific preview alive. The generic contract is delivered by
  `ProjectBrowserSession`, and the parent lane consumes it in the surface.
- **No live application run.** The evidence below is unit and process
  evidence over real temporary directories.

## Evidence

`fvm flutter test test/coding_agent/project_operations/` — 22 tests, all
passing; `fvm dart analyze` clean over
`lib/coding_agent/project_operations` and
`test/coding_agent/project_operations`. The pre-existing suites that touch
the `ProductWorkspaceTooling` seam
(`product_workspace_tooling_test.dart`,
`product_verification_profile_test.dart`,
`product_coding_change_view_test.dart`,
`harness_receipt_pages_test.dart`,
`native_binding_adoption_test.dart`) still pass — 20 tests, all passing.

The declaration-file lane adds its own evidence, without touching the seam
above: `fvm flutter test test/coding_agent/project_operations/` — 19 tests
(all passing: 11 session, 6 panel, 2 pre-existing seam tests), `fvm dart
analyze` clean over `lib/coding_agent/project_operations` and
`test/coding_agent/project_operations`, and in `oka_core`
`dart test test/project_operations/project_operation_profile_codec_test.dart`
— 8 tests, all passing, with `dart analyze` clean over
`lib/src/project_operations` and `test/project_operations`. The codec tests
are unit tests over declarations and refusals; no test in that file starts a
process, and none of them is a live app run.

The tests are real processes in real temporary directories: a declared
command that succeeds, one that fails with an exit code and error output,
one that cannot start, an argument with spaces that must stay one argument,
an explicit working directory (project root and an external package root),
an environment override that is present only when declared, an external
package root referenced rather than copied, a deadline that stops the
command instead of abandoning it, a borrowed endpoint that is never killed,
an owned process that is closed safely, a serve process that never becomes
ready and is stopped, and a failed attach that keeps the last known good
target.

A cancel on this surface really stops the command: the bounded run performs
the same identity-gated tree stop the deadline performs, and the panel reports
whether that stop was verified. A stop that could not be verified is a
failure that keeps its recovery receipt, not a clean cancel. Leaving the
surface requests the cancellation, joins the command and the serve
attachment, and only then releases an owned target; a cleanup that could not
be verified keeps the target and its lease, because a swallowed failure must
not forget the owner of a process that may still be running. The browser
session's serve attachment has no cancellation seam of its own — that
session owns the spawn — so it is joined and then released under the
ownership law.

## References

- [PLAN.md](../PLAN.md) — the consumer stages and the phase gates.
- [ADR 0016](0016-reversible-code-candidates-over-native-owners.md) —
  reversible candidates over native owners.
- [ADR 0019](0019-two-products-one-surface.md) — one product, two densities.
- [ADR 0022](0022-general-browser-window.md) — the general embedded browser
  window that consumes this session's URL.
- oka
  [ADR-0018](../../../oka/docs/decisions/0018-process-lifecycle-leases.mdx)
  — process leases: identity over pid, ownership before signalling.
