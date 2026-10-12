# configs/automation.json

Desktop-automation wiring for Last Answer
(universal automation toolkit, ADR 0064 in dart_flutter_packages).

- `residentServe` — the MCP endpoint of the resident serve
  (`serve --os --http 8192`), kept alive by oka's supervisor via
  `~/xs/ecsai_harness/tool/uatk_serve.sh` (one converge pass: spawns
  when down, budgets restarts, records lease facts). The job plane's
  receipts are durable under `~/.uatk/jobs`.
- `app` — how automation anchors to the running app: by bundle id
  (`ax://bundle/dev.xsoulspace.lastAnswer`), so observation, semantic
  writes (`setValue`/`elementAction`), and pid-scoped typing all work
  while Last Answer stays in the background.
- `plans` — declarative acceptance plans (the toolkit's plan YAML),
  run with
  `dart run ~/xs/storage_problem/dart_flutter_packages/pkgs/universal_automation_toolkit/bin/universal_automation.dart run --plan <plan>`
  or submitted to the resident serve's `automation_run_plan` MCP tool.

The desktop tier needs the Accessibility TCC grant for the executing
Dart binary.
