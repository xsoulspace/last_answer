# UI_MODELS_KNOWLEDGE.md

**Owns:** the Models surface (DESIGN v5) — three lenses over ONE palette
document (`models_view.dart`, `catalog_lens.dart`, ladder/bindings, observe)
+ the agent-config document (`agent_config/` — Zed-style agent_config.json,
persistence io/prefs, settings pane, subscription account panes).

**How to extend:** model surface verbs ride the widget-free
`PaletteCandidateModel`; config keys go through the `agent_config/` doc, never
shared_preferences directly. LANE-TRUTH + ZED REASONING + BOUNDED-LOOSE laws:
see the maintain-last-answer skill.
