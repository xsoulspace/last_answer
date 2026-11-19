import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lastanswer/bootstrap.dart';
import 'package:lastanswer/ui_browser/browser_mcp_tools.dart';
import 'package:lastanswer/ui_documents/agent_mcp_tools.dart';
import 'package:lastanswer/chat/realm_chat_mcp_tools.dart';
import 'package:lastanswer/ui_inspector/world_inspector_tools.dart';
import 'package:lastanswer/mcp/app_mcp_tools.dart';
import 'package:lastanswer/mcp/doc_mcp_tools.dart';
import 'package:lastanswer/mcp/shell_mcp_tools.dart';
import 'package:lastanswer/mcp/storage_mcp_tools.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    final binding = MCPToolkitBinding.instance
      ..initialize()
      ..initializeFlutterToolkit();
    assert(() {
      // NOTE: ensureSemantics here caused a continuous embedder task
      // churn on macOS (semantics updates every frame). The toolkit
      // enables semantics lazily on first snapshot instead.
      // Agent-driven storage tools (debug/profile only).
      unawaited(
        binding.addEntries(
          entries: {
            ...appMcpEntries(),
            ...browserMcpEntries(),
            ...storageMcpEntries(),
            ...docMcpEntries(),
            ...agentMcpEntries(),
            ...realmChatMcpEntries(),
            ...shellMcpEntries(),
            ...worldInspectorMcpEntries(),
          },
        ),
      );
      return true;
    }());
    unawaited(bootstrap());
  }, MCPToolkitBinding.instance.handleZoneError);
}
