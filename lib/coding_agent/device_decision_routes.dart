import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_laya/xsoulspace_inference_laya.dart';

/// ADR 0051 Phase 4 — the phone-join decision-route composition.
///
/// Desktops host the LOCAL tier: the laya endpoint on this machine, bound
/// exactly as before. Phones (Android first, iPad later) join the mesh as
/// human participants: nothing on the device can host laya or AFM, so the
/// same `laya` backend routes over the mesh to a PEER's laya endpoint
/// (executionLocation local + networkRequirement required → the meshPeer
/// tier) instead of pointing at 127.0.0.1 and reporting a dead probe.
/// Hosting models on the phone itself is a separate, future capability
/// (ADR 0051 non-claims) — the routing here is what makes the join useful.
///
/// [platform] defaults to the running OS and is injectable for tests.
bool deviceHostsLocalLaya(final String? platform) =>
      switch (platform ?? Platform.operatingSystem) {
        'macos' || 'linux' || 'windows' => true,
        _ => false,
      };

/// The `laya` decision binding for THIS device.
///
/// On a local-capable desktop this is the plain loopback binding (local
/// host tier, unchanged behavior). On a phone, [endpoint] names a MESH
/// PEER's System One endpoint (the paired Mac's LAN address) and the
/// provider's capability facts say so honestly: local execution,
/// network required. The ADR 0051 [RoutedDecisionProvider] wraps the peer
/// route so a second paired host can be added later without touching this
/// seam, and so an unhealthy peer fails over when more routes exist.
JevClientBinding layaBindingForDevice({
  required final String? platform,
  required final Uri? endpoint,
  final LayaServeRuntime? runtime,
  final String? apiKey,
  final void Function(Map<String, Object?> event)? onDiagnosticEvent,
  final http.Client? httpClient,
}) {
  final localCapable = deviceHostsLocalLaya(platform);
  final effectiveRuntime =
      runtime ??
      LayaServeRuntime(healthEndpoint: endpoint?.replace(path: '/health'));
  if (localCapable) {
    return layaDecisionBinding(
      runtime: effectiveRuntime,
      apiKey: apiKey,
      endpoint: endpoint,
      onDiagnosticEvent: onDiagnosticEvent,
      httpClientOverride: httpClient,
    );
  }
  final peerProvider = LayaLocalDecisionProvider(
    runtime: effectiveRuntime,
    apiKey: apiKey,
    endpoint: endpoint,
    httpClient: httpClient,
    onDiagnosticEvent: onDiagnosticEvent,
    networkRequirement: DecisionNetworkRequirement.required,
  );
  return JevClientBinding(
    provider: RoutedDecisionProvider(
      id: 'laya_peer_routes',
      routes: [peerProvider],
    ),
    model: 'laya',
    routerModelId: 'laya-decision',
  );
}
