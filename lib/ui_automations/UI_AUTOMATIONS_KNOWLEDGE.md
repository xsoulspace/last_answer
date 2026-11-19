# AUTOMATIONS_KNOWLEDGE.md

**Owns:** the automations experience surface — declared automations plus this
device's supervisor runtime (the ONE ecsai daemon + scheduler adapter), as a
rail-reachable surface (`rail.automations`, the 4th rail button) rather than a
buried settings pane. The settings tab links here; it does not own this domain.

**Key files:**

- `automations.dart` — barrel (the domain's public API; cross-folder imports
  go through it).
- `automations_surface.dart` — the surface view (the automations tab face).
- `supervisor_agent_client.dart` / `supervisor_agent_provider.dart` — the
  oka_supervisor DesiredState client + its provider (read surface per oka
  ADR-0041 §6).
- `supervisor_service.dart` / `supervisor_service_io.dart` /
  `supervisor_service_stub.dart` — the service seam; `io` is the real
  daemon-side lane, `stub` serves web builds (conditional on `dart.library.io`).
- `supervisor_execution.dart` / `supervisor_execution_stub.dart` — execution
  lane + its web stub (same conditional pair).
- `supervisor_panel.dart` / `supervisor_view.dart` — panel chrome + view.

**How to extend:** a new automation surface row goes in the section list of
`automations_surface.dart` (+ EN/IT/RU strings: the three arbs in packages/la_locale + `just gen-l10n`); a new
supervisor verb goes through the client, never through a widget. App services
that are domains (not settings) belong in their own surface folder like this
one — see docs/ARCHITECTURE.md §3 (state placement) for why they leave
`lib/settings/`. Moved here 2026-11-19 from `lib/settings/features/supervisor_*`
(the automations-burial lesson).
