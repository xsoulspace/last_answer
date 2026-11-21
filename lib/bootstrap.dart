// 4c — crash reporting rides the LOCAL lane (lib/crash/crash_reports.dart):
// privacy-first by the project's own law, zero new dependencies. The
// Firebase re-enable stays an owner decision (plan v5 4c named the
// choice; the native gradle plugins remain wired for that day).
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/crash/crash_reports.dart';
import 'package:lastanswer/mcp/app_mcp_tools.dart';
import 'package:lastanswer/mcp/doc_mcp_tools.dart';
import 'package:lastanswer/mcp/shell_mcp_tools.dart';
import 'package:lastanswer/mcp/storage_mcp_tools.dart';
import 'package:lastanswer/store/bindings/noop.dart';
import 'package:lastanswer/ui_browser/browser_mcp_tools.dart';
import 'package:lastanswer/ui_chat/realm_chat_mcp_tools.dart';
import 'package:lastanswer/ui_documents/agent_mcp_tools.dart';
import 'package:lastanswer/ui_inspector/world_inspector_tools.dart';
import 'package:lastanswer/ui_root/last_answer_app.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// Boots the app for ONE store identity (ADR 0037): the per-store
/// entrypoint passes its hand-typed [MonetizationStoreBinding]; only the
/// backend that binding imports compiles into the kernel. Default: the
/// store-neutral [noopStoreBinding] (dev builds).
Future<void> bootstrap({
  MonetizationStoreBinding storeBinding = noopStoreBinding,
}) async {
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
  }(), 'agent-driven mcp entries (debug/profile only)');
  CrashReports.install();
  CrashReports.guard(() {
    runApp(LastAnswerApp(storeBinding: storeBinding));
  });
}
