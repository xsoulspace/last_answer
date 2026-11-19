# UI_SETTINGS_KNOWLEDGE.md

**Owns:** the settings experience — one-scroll section registry
(`settings_sections.dart` + `settings_screen.dart`, scroll-spy TOC + jump
filter), the features UI (mesh panels, storage backends, GitHub sync,
locale/theme), changelog, supporter/IAP views.

**How to extend:** add a `SettingsSection` row, not a new tab; app services
are NOT settings — they get their own domain folder (the automations lesson).
Domain services live elsewhere (journal/, data_agents/).
