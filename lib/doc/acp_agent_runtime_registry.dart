import 'package:lastanswer/doc/acp_agent_runtime.dart';

/// One ACP agent process per chat document (never a shared singleton across
/// docs): two conversations must not interleave turns inside one CLI
/// process, and per-doc sessions keep their agent alive independently.
///
/// Runtimes are app-lifetime: navigating away from a chat doc keeps its
/// agent (and its ACP session) alive; [disposeAll] is for shutdown/tests.
final class AcpAgentRuntimeRegistry {
  AcpAgentRuntimeRegistry({this.clientFactory = spawnAcpClient});

  final AcpClientFactory clientFactory;

  final Map<String, AcpAgentRuntime> _runtimes = {};
  final Map<String, String> _startedAgentKeys = {};

  /// The runtime owning [docId], creating it lazily.
  AcpAgentRuntime forDoc(final String docId) => _runtimes.putIfAbsent(
    docId,
    () => AcpAgentRuntime(clientFactory: clientFactory),
  );

  /// The runtime for [docId], or null when the doc never started one.
  AcpAgentRuntime? maybe(final String docId) => _runtimes[docId];

  /// Starts the doc's runtime on [config] (idempotent), restarting it first
  /// when the selected agent changed since the last start (a switch from
  /// Gemini to Codex must not reuse the old process).
  Future<AcpAgentRuntime> ensureStarted(
    final String docId,
    final String agentKey,
    final AcpRuntimeConfig config,
  ) async {
    final runtime = forDoc(docId);
    final startedKey = _startedAgentKeys[docId];
    if (startedKey != null && startedKey != agentKey) {
      await runtime.stop();
    }
    if (!runtime.isReady) {
      await runtime.start(config);
    }
    _startedAgentKeys[docId] = agentKey;
    return runtime;
  }

  /// Stops and drops every runtime (app shutdown, tests).
  Future<void> disposeAll() async {
    for (final runtime in _runtimes.values) {
      await runtime.stop();
    }
    _runtimes.clear();
    _startedAgentKeys.clear();
  }
}
