import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_laya/xsoulspace_inference_laya.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

// No laya/openrouter imports for the wire adapter itself: LA composes the
// capability through afm's `layaDecisionBinding`; the wire server runs as a
// separate process.

/// Drives the readiness probe through a canned outcome instead of real
/// sockets: the widget-test binding mocks ALL HttpClient traffic to 400 —
/// and any status below 500 counts as ALIVE for the laya probe — so a
/// "no server" fixture is unreachable that way. Negative status =
/// connection-refused. Extends BaseClient so the convenience `get` exists
/// (a bare `implements http.Client` would NoSuchMethod into the probe's
/// catch-all and always read as down).
final class _CannedLayaClient extends http.BaseClient {
  _CannedLayaClient(this.status);

  final int status;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (status < 0) throw StateError('connection refused');
    return http.StreamedResponse(Stream.value(const <int>[]), status);
  }
}

void main() {
  group('HarnessHostConfig laya backend', () {
    test('buildBackend registers the local decision binding', () {
      final config = HarnessHostConfig(
        backend: 'laya',
        model: 'laya',
        layaBinding: layaDecisionBinding(),
      );

      final backend = config.buildBackend();

      expect(backend.backend, 'laya');
      expect(
        config.layaBinding?.provider.capabilities.executionLocation,
        DecisionExecutionLocation.local,
      );
      expect(
        config.layaBinding?.provider.capabilities.networkRequirement,
        DecisionNetworkRequirement.none,
      );
      expect(config.layaBinding?.routerModelId, 'laya-decision');
    });

    test('no binding → resolvable without a key (local capability)', () {
      const config = HarnessHostConfig(backend: 'laya');

      expect(config.buildBackend(), isNotNull);
      expect(config.openRouterKeyResolvable, isTrue);
    });

    test('copyWith swaps and clears the laya binding', () {
      final first = layaDecisionBinding();
      final second = layaDecisionBinding();
      final base = HarnessHostConfig(backend: 'laya', layaBinding: first);

      final switched = base.copyWith(layaBinding: second);
      expect(identical(switched.layaBinding, first), isFalse);

      final cleared = switched.copyWith(clearLayaBinding: true);
      expect(cleared.layaBinding, isNull);
    });
  });

  group('AgentDocSurface laya readiness gate', () {
    ProjectModelDoc layaDoc() => (ProjectModel.emptyAgent() as ProjectModelDoc)
        .copyWith(agent: const AgentDocModel(backend: 'laya'));

    testWidgets(
      'no laya-serve answering → the pre-turn gate names the endpoint and '
      'no turn-ready config is composed',
      (final tester) async {
        AgentDocSurface.layaRuntimeFactory = (final endpoint) =>
            LayaServeRuntime(
              healthEndpoint: endpoint,
              httpClient: _CannedLayaClient(-1),
            );
        addTearDown(() => AgentDocSurface.layaRuntimeFactory = null);

        final controller = HarnessSessionController(
          config: const HarnessHostConfig(),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgentDocSurface(doc: layaDoc(), controller: controller),
            ),
          ),
        );

        await pumpUntil(tester, () => controller.error != null);

        expect(
          controller.error,
          contains('no laya-serve answering at'),
          reason:
              'the gate must name the endpoint instead of failing '
              'mid-turn with a typed unavailable',
        );
        expect(
          controller.config.layaBinding,
          isNull,
          reason: 'the gate refuses BEFORE composing the turn-ready config',
        );
      },
    );

    testWidgets(
      'healthy laya-serve → sync passes, the binding composes, no error',
      (final tester) async {
        AgentDocSurface.layaRuntimeFactory = (final endpoint) =>
            LayaServeRuntime(
              healthEndpoint: endpoint,
              httpClient: _CannedLayaClient(200),
            );
        addTearDown(() => AgentDocSurface.layaRuntimeFactory = null);

        final controller = HarnessSessionController(
          // The scripted seam keeps the start path off any real provider —
          // the gate under test is the probe, not generation.
          config: HarnessHostConfig(
            handlerFactory: (_) => ScriptedWriteMover('laya.dart', 'x'),
          ),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgentDocSurface(doc: layaDoc(), controller: controller),
            ),
          ),
        );

        await pumpUntil(tester, () => controller.config.layaBinding != null);
        // Give a failing gate its window before asserting the clean pass.
        await pumpUntil(tester, () => controller.error != null, maxCycles: 20);
        await tester.pump();

        expect(
          controller.error,
          isNull,
          reason: 'a healthy endpoint must not raise the pre-turn gate',
        );
      },
    );
  });
}
