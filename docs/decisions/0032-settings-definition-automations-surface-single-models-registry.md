# ADR 0032: Settings is preferences; automations and models are surfaces

Status: Accepted (owner directive 2026-11-19)
Date: 2026-11-19
North Star impact: applies

## The definition law

Settings holds **durable choices about how the app behaves for this
human** — appearance, language, notes policy, data & sync, ACP agent
servers, account, about. The test for any item: if it has run-state, a
schedule, or a live process behind it, it is a surface; if it is a
choice that persists and rarely changes, it is a setting.

This supersedes the placement of two features and retires the
three-button rail law's completeness (action bar header, owner law
2026-11-10): the rail grows to FOUR buttons — search, actors,
automations, settings. Each button remains a distinct top-level mode;
automations earned the slot the same way models earned its surface.

## Automations is a feature, not a setting

The supervisor pane (declared automations, per-device records, drift,
the schedule editor) was mounted inside Settings → Storage — zero
discovery, wrong kind. It becomes the `automations` surface
(`kAutomationsSurfaceId`), opened from `rail.automations`, the `+`
picker and the palette. The supervisor files move from
`lib/settings/features/` to `lib/automations/`. The mesh-tasks settings
page dies: the Boards surface already hosts the mesh task rows
(`_MeshTasksSection`, redesign §2.2.4 — the settings page was the
duplicate).

## One models registry

Providers, models, chat defaults and subscription lanes are edited in
exactly ONE place: the Models surface over the world palette (the
dispatch truth). The settings agent tab's providers section, chat
defaults section and the ChatGPT/Grok subscription panes move there;
the pane keeps only ACP agent servers and the tab becomes "Agents".
`agent_config.json` keeps `agentServers` as the live ACP source; its
`providers`/`chat` entries remain as read-only fallbacks (the brain
pickers' hosted-model derivation) until a named sunset — no silent
data migration, no deleted user data. Palette-declared providers reach
the same pickers as rungs, so nothing is lost by removing the
duplicate editor.

## Settings reads as one document

The settings surface stops paging (General/Agent/Account PageView
retired) and renders ONE endless scroll of registered sections
(`SettingsSection` registry: You, Appearance, Notes, Data & sync,
Agents, Account, About) with a scroll-spy anchor column at wide widths
(hidden below the models 640px compact law) and a type-to-jump filter
over the rows' widget keys. Section = registry entry; growth needs no
layout surgery. Instant-apply controls only in settings proper;
draft+save stays only where authority requires it (the agents'
document, the models' propose/apply). GitHub sync, storage backends
and export/import merge into one Data & sync section (the double
GitHub entry dies).

Sources: ADR 0024 (surface registry), ADR 0031 (subscription is a
provider type), DESIGN.md (document-first, one grid, keys as
contract), the settings refactor analysis 2026-11-19.
