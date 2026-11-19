# UI_BOARDS_KNOWLEDGE.md

**Owns:** the planning board surface (`board_view.dart`) — the always-visible
grid over the ecsly_boards replicas. Its data lives in
`ecs_plugins/boards/` (replica + bridge); this folder is presentation only.

**How to extend:** board ops stay quiet always-visible buttons
(`board.op.*` keys); columns/cards via the fractional-rank replica verbs.
