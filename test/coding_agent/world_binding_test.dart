// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding_sheet.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/trace.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';

/// A scripted stand-in for the facade source (the pane's test seam —
/// the same shape the existing external-attach test uses).
final class _ScriptedBindingSource extends TraceSource {
  @override
  Future<InspectorTrace?> sample() async => InspectorTrace(
    rows: const [],
    metrics: const {'sessionId': 'sess-test'},
  );
}

void main() {
  group('parseManualBinding', () {
    test('accepts an http endpoint and normalizes the trailing slash', () {
      final binding = parseManualBinding('http://127.0.0.1:28905');
      expect(binding, isNotNull);
      expect(binding!.endpoint, 'http://127.0.0.1:28905/');
      expect(binding.worldId, 'manual-127.0.0.1-28905');
    });

    test('refuses garbage, scheme-less text, and non-http schemes', () {
      expect(parseManualBinding('not a url'), isNull);
      expect(parseManualBinding('127.0.0.1:28905'), isNull);
      expect(parseManualBinding('ftp://127.0.0.1:21'), isNull);
      expect(parseManualBinding('http://'), isNull);
    });
  });

  group('WorldBindingChoice', () {
    test('dismissed is not picked; embedded is picked with null binding', () {
      expect(const WorldBindingChoice.dismissed().picked, isFalse);
      const embedded = WorldBindingChoice.embedded();
      expect(embedded.picked, isTrue);
      expect(embedded.binding, isNull);
      const world = WorldBindingChoice.world(
        WorldBindingModel(worldId: 'w', endpoint: 'http://x/'),
      );
      expect(world.picked, isTrue);
      expect(world.binding?.worldId, 'w');
    });
  });

  group('a bound doc pane', () {
    testWidgets('samples its world and names it on the rule',
        (final tester) async {
      final binding = WorldBindingModel(
        worldId: 'harnessd-test',
        endpoint: 'http://127.0.0.1:59999',
        displayName: 'test world',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldInspectorPane(
              pollInterval: const Duration(milliseconds: 10),
              showScene: false,
              binding: binding,
              bindingSourceBuilder: (final _) => _ScriptedBindingSource(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // The rule names the bound world; the sample flows into the
      // projection (equal readers — the headless verb sees the same).
      expect(find.textContaining('WORLD · TEST WORLD'), findsOneWidget);
      expect(
        WorldInspectorPane.lastProjection?.sampledSession,
        'sess-test',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('an unreachable bound world names the arm command',
        (final tester) async {
      final binding = WorldBindingModel(
        worldId: 'harnessd-gone',
        endpoint: 'http://127.0.0.1:1',
        displayName: 'gone world',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldInspectorPane(
              pollInterval: const Duration(milliseconds: 10),
              showScene: false,
              binding: binding,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.textContaining('unreachable'), findsOneWidget);
      expect(find.textContaining('harnessd --serve'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });
  });
}
