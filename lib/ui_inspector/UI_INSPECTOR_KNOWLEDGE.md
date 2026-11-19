# UI_INSPECTOR_KNOWLEDGE.md

**Owns:** the world inspector surfaces — pane/page/tools, conversation view,
model picker, work verbs, world bindings (sheet/store), seats (io/stub/lease
conditional set), external-world discovery, scripted session fixture.

**How to extend:** a new inspector tool registers through
`world_inspector_tools.dart`; seat/platform variants follow the io/stub
conditional pattern (`dart.library.io` gate). Reads harness worlds via
`data_agents/`, never through UI siblings.
