import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/device_decision_routes.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

/// ADR 0051 Phase 4 — the phone joins the mesh as a human participant:
/// the `laya` backend on Android/iPad routes to a mesh PEER's System One
/// endpoint with honest capability facts (local execution, network
/// required), while desktops keep the loopback local-host binding.
void main() {
  test('desktop keeps the loopback local-host binding', () {
    final binding = layaBindingForDevice(
      platform: 'macos',
      endpoint: Uri.parse('http://127.0.0.1:8000/v1/systemone'),
    );
    final provider = binding.provider;
    expect(provider.id, 'laya_local');
    expect(
      provider.capabilities.executionLocation,
      DecisionExecutionLocation.local,
    );
    expect(
      provider.capabilities.networkRequirement,
      DecisionNetworkRequirement.none,
    );
    expect(decisionRouteTierOf(provider), DecisionRouteTier.localHost);
    expect(binding.routerModelId, 'laya-decision');
  });

  test('android routes to the mesh peer with required-network facts', () {
    final binding = layaBindingForDevice(
      platform: 'android',
      endpoint: Uri.parse('http://192.168.1.20:8000/v1/systemone'),
    );
    final provider = binding.provider;
    // The routed provider's facts follow its (single) peer route.
    expect(
      provider.capabilities.executionLocation,
      DecisionExecutionLocation.local,
      reason: 'a LAN peer executes locally on ITS device',
    );
    expect(
      provider.capabilities.networkRequirement,
      DecisionNetworkRequirement.required,
      reason: 'the phone reaches the peer over the mesh network',
    );
    expect(decisionRouteTierOf(provider), DecisionRouteTier.meshPeer);
    expect(binding.routerModelId, 'laya-decision');
    expect(binding.model, 'laya');
  });

  test('ios (iPad) routes identically to android', () {
    final binding = layaBindingForDevice(
      platform: 'ios',
      endpoint: Uri.parse('http://192.168.1.20:8000/v1/systemone'),
    );
    expect(
      decisionRouteTierOf(binding.provider),
      DecisionRouteTier.meshPeer,
    );
  });

  test('an unready peer surfaces typed unavailable, not a crash', () {
    final binding = layaBindingForDevice(
      platform: 'android',
      endpoint: Uri.parse('http://192.168.1.20:8000/v1/systemone'),
    );
    // Readiness is a snapshot and must not perform network I/O here.
    expect(binding.provider.readiness.isReady, isFalse);
  });
}
