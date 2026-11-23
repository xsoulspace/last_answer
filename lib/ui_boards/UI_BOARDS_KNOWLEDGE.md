# UI_BOARDS_KNOWLEDGE.md

**Owns:** the boards surfaces — `board_view.dart` (the planning grid),
`realm_task_board.dart` (the realm coordination board: the durable task
queue rendered in canonical `BoardTaskStatus` lanes over the journal
projection, with the workspace + attention filters), `task_detail_dialog.dart`
(the ONE durable task truth pane the inbox and the board share),
`mesh_task_doc_link.dart` (the ACP session link), `delegation.dart`
(the delegate seam type + the card→task provenance ledger). Data lives in
`ecs_plugins/boards/` (replicas over `LwwReplicaCore`, bridge); the realm
rows come from `data_journal/world_state_service.dart` (the `durable_tasks`
projection). This folder is presentation only — ADR 0039 is the law.

**Laws:** the queue is the lifecycle authority, a card renders it
(`cardStatusOfQueue`; `unknown` → failed lane, honestly); planning cards
never become journal rows; the board never dispatches by itself (no
delegate seam mounted, no op); provenance is app-side ledger state, never a
replica field (the planning wire is byte-frozen).

**How to extend:** board ops stay quiet always-visible buttons
(`board.op.*` keys); realm rows key `board.realm.*`; new filters are view
state on `RealmTaskBoard`, never new task truth. The delegate seam is
shell-mounted (`surfaces.dart` `_delegateBoardCard`); a refusal renders in
words.
