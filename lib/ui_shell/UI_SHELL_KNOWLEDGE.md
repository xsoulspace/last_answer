# UI_SHELL_KNOWLEDGE.md

**Owns:** the chrome — rail, rooms column, tab strips, pane tree, command
palette, surface registry (`surfaces.dart` = THE manifest), status edge,
actor info surface, theme tokens, miniwindows. CHROME ONLY: never a domain.

**How to extend:** a new surface = a row in `surfaces.dart` + its own `ui_*`
domain folder + its knowledge file. Features never import this folder's files
except through the registry. The layout document is `shell_layout.dart`
(`shell.views.v4` + `shell.rooms.docked`).
