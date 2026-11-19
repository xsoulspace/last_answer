# ECS_WORLD_KNOWLEDGE.md

**Owns:** the ONE in-process ecsly World — assembly, components, journal feed,
creature layer. The ecsly anatomy, visible in file names: `world.dart`
(EcsScope/controller assembly + fixed-step systems), `world_components.dart`
(component schema), `world_feed.dart` (the journal cursor fold),
`creatures.dart` + `creature_mark.dart` (species/mood/painter).

**How to extend:** register new components in `world_components.dart` + install
systems in `world.dart`'s schedules (pin order with `.then()`/names — ecsly
resolves unordered systems alphabetically). `package:ecsly` kernel imports are
legal ONLY here and in `ecs_plugins/`. Widgets read via `ecsly_flutter`
selectors; mutations go through actions, never widget-state writes.
