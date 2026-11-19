# ECS_PLUGINS_KNOWLEDGE.md

**Owns:** the LA-side integration of each consumed ecsly plugin, one subfolder
per plugin: `boards/` (ecsly_boards: MeshTaskBoard, MeshBoardBridge,
PlanningBoardReplica/Controller), `conversation/` (ecsly_conversation shim),
`scene/` (ecsly_flutter_scene: the workbench scene binding), `world_sync/`
(ecsly_world_sync mounts — grows here).

**How to extend:** a newly consumed plugin gets a subfolder + a section here;
kernel imports stay inside this folder and `ecs_world/`. Replica/store laws
(snapshot discipline, HLC, absorption windows) are pinned by the tests that
cover each replica.
