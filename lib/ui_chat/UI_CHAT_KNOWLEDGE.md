# UI_CHAT_KNOWLEDGE.md

**Owns:** the chat experience domain — the conversation surface
(`world_chat_surface.dart`), actor widgets (avatar/picker/profile editor/
presence/status marks), brain & palette chips, channel-members UI, the media
beat card, and the realm-chat MCP tool registrations.

**Key files:** `world_chat_surface.dart` (the conversations surface mounted by
the shell registry), `actor_status.dart` + `actor_presence.dart` (the presence
fold UI), `palette_health.dart` / `brain_health_dot.dart` (lane/health chips).

**How to extend:** a new chat surface row goes through the surface registry
(`ui_shell/surfaces.dart`); its services belong in `data_journal/` — this folder is
presentation + domain-local glue. Widget keys follow the `worldchat.*` /
`rooms.*` contract (DESIGN §6).
