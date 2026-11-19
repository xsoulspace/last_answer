# UI_DOCUMENTS_KNOWLEDGE.md

**Owns:** the document domain — the recursive doc editor (`doc_view.dart`,
`code_view.dart`), ACP agent runtime catalog + per-doc process registry,
doc inference ports (ACP + OpenRouter), session reference store, the chat
permission policy, and the agent-doc surface (`agent_doc_surface.dart`, the
DESIGN reference implementation) with its MCP verbs (`agent_mcp_tools.dart`).

**How to extend:** a new doc capability = a feature file here + its verbs
through the doc runtime; agent-facing verbs also register in the MCP catalog
contracts. `chat_permission_policy.dart` may move to `journal/` when realm
permissions consolidate (noted drift).

**Legacy migration (ADR 0002):** `legacy_project_migration.dart` converts
legacy note/idea rows into docs at open time — deterministic id
(`legacy-note-<id>` / `legacy-idea-<id>`), idempotent, NON-DESTRUCTIVE (the
original row and its backups stay untouched). `project_view.dart` is the
single doc→surface map (doc: tabs, /home/d, changelog) and renders the
`_LegacyMigrationHost` spinner→doc flow for legacy rows. Note image files
remain on the `note-assets/` plane via `data_journal/note_asset_store.dart`.
