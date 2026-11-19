# UI_LEGACY_KNOWLEDGE.md

**Owns:** the FROZEN pre-shell surfaces — `home/`, `idea/`, `note/`,
`legacy_kit/` (the pre-la_ui widget kit). Quarantine law: no new code, no new
importers from outside; retirement only via the explicit user-visible
migration ADR 0002 requires (ideas/notes hold real user data — read old
format until migration runs; never delete storage on open). Entries today:
`router.dart`, `ui_shell/view_documents.dart`, ui_settings exports.
