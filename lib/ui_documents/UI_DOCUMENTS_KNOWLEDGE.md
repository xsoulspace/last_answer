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
