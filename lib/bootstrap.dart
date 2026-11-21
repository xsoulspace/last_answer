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
import 'package:oka_store/oka_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// Boots the app for ONE store identity (ADR 0037). The entrypoint
/// passes its hand-typed [MonetizationStoreBinding] — REQUIRED, no
/// default: a forgotten binding must fail loudly (analyze catches it at
/// the call site), not silently ship a kernel that sells nothing
/// (asserts vanish in release). Dev mains pass [noopStoreBinding]
/// explicitly.
///
/// Identity is verified against the composition (oka ADR 0055): a
/// delivery bakes its variant's store key as the `OKA_STORE` dart
/// define, and a kernel whose binding names a different store refuses
/// to boot — the one-identity law holds end to end, checked at runtime
/// (a real check, not an assert).
Future<void> bootstrap({
  required MonetizationStoreBinding storeBinding,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Deliberate String.fromEnvironment: the OKA_STORE define is the
  // build-time identity contract baked by the oka delivery (ADR 0037).
  // ignore: do_not_use_environment
  const compiledStoreKey = String.fromEnvironment(okaStoreDefine);
  if (compiledStoreKey.isNotEmpty &&
      storeBinding.key.name != compiledStoreKey) {
    throw StateError(
      'store binding mismatch: this kernel was built for '
      '"$compiledStoreKey" (the $okaStoreDefine define baked by the oka '
      'delivery) but this entrypoint booted the '
      '"${storeBinding.key.name}" binding. Import the matching binding '
      'from lib/store/bindings/ in the entrypoint.',
    );
  }
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
