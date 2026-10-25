# ADR 0020 — Execute automations while Last Answer is open

Status: accepted for implementation; live qualification pending

Date: 2026-10-21

The approved 30-day delivery plan makes Last Answer the local automation
workspace. Keep its existing plan editor and Oka `SpecStore`; execute through
Oka's app-scoped supervisor session, not a second scheduler. Opening settings
does not execute saved plans. The human explicitly enables execution, then the
app retains one session across pane navigation. Closing the app suspends
scheduling and joins owned teardown. No background service is installed.

Process declarations use explicit argv (JSON array for new edits), never shell
evaluation. Agent jobs resolve an injected provider from the current authorized
world; absence is a visible capability refusal, never provider substitution.
Mobile remains the paired companion; local process execution is desktop-only.

Execution results, errors and bounded logs are visible beside existing plan
status. Pause stops future dispatch and cancellation joins the active pass.
This is independent of the grid/workshop changes already in progress.
