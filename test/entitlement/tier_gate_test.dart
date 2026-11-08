/// Plan v5 4b — the tier layer's laws, pinned:
/// - the pure `tierAllows` table: every listed PRO feature answers
///   `isPro`; the FREE core (conversations, documents, notes, basic
///   artifact editing) has NO feature and is never gated;
/// - the provisional FREE cast limit (5, TODO owner) is pinned by name;
/// - `ProGate` renders the child when Pro, the quiet NAMED ABSENCE
///   (with the upgrade route) when free, and FAILS OPEN when no
///   entitlement layer is mounted (hermetic surfaces are never locked
///   out by a layer that was never installed).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:lastanswer/entitlement/tier_gate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(
  final Widget child, {
  final ProEntitlement? entitlement,
  final bool provide = true,
}) {
  Widget body = Scaffold(body: child);
  if (provide) {
    body = ChangeNotifierProvider<ProEntitlement>.value(
      value: entitlement ?? ProEntitlement(),
      child: body,
    );
  }
  return MaterialApp(home: body);
}

const _childKey = ValueKey('tier.child');

Widget _gated(final TierFeature feature) => ProGate(
  feature: feature,
  child: const Text('unlocked', key: _childKey),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tierAllows — the pure table', () {
    test('every listed PRO feature answers isPro', () {
      for (final feature in TierFeature.values) {
        expect(
          tierAllows(feature, isPro: true),
          isTrue,
          reason: '${feature.name} must open for PRO',
        );
        expect(
          tierAllows(feature, isPro: false),
          isFalse,
          reason: '${feature.name} must be quiet for FREE',
        );
      }
    });

    test('the plan\'s PRO list is exactly the gated surface set', () {
      expect(
        TierFeature.values.map((final e) => e.name).toSet(),
        {
          'paletteEditor',
          'worldInspector',
          'terminal',
          'meshSync',
          'daemonControl',
          'traceDepth',
          'acpBridge',
          'castBeyondFreeLimit',
        },
      );
    });

    test('the provisional FREE cast limit is pinned at 5 (TODO owner)', () {
      expect(freeCastLimit, 5);
      for (var count = 0; count <= freeCastLimit; count++) {
        expect(tierAllowsCastCount(count, isPro: false), isTrue);
      }
      expect(tierAllowsCastCount(freeCastLimit + 1, isPro: false), isFalse);
      expect(tierAllowsCastCount(freeCastLimit + 1, isPro: true), isTrue);
      expect(tierAllowsCastCount(1000, isPro: true), isTrue);
    });
  });

  group('ProGate — the widget law', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    testWidgets('free renders the quiet named absence, not the child', (
      final tester,
    ) async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      await tester.pumpWidget(
        _wrap(_gated(TierFeature.paletteEditor), entitlement: entitlement),
      );
      expect(find.byKey(_childKey), findsNothing);
      expect(
        find.byKey(const ValueKey('tier.absence.paletteEditor')),
        findsOneWidget,
      );
      // The absence NAMES what is missing and offers the upgrade route.
      expect(find.textContaining('palette editor'), findsOneWidget);
      expect(find.textContaining('PRO'), findsOneWidget);
      expect(find.textContaining('See Plans'), findsOneWidget);
      entitlement.dispose();
    });

    testWidgets('pro renders the child', (final tester) async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      await entitlement.setDevOverride(true);
      await tester.pumpWidget(
        _wrap(_gated(TierFeature.paletteEditor), entitlement: entitlement),
      );
      expect(find.byKey(_childKey), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tier.absence.paletteEditor')),
        findsNothing,
      );
      entitlement.dispose();
    });

    testWidgets('no entitlement layer mounted fails OPEN', (
      final tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_gated(TierFeature.terminal), provide: false),
      );
      expect(find.byKey(_childKey), findsOneWidget);
    });

    testWidgets('the cast absence names the provisional limit', (
      final tester,
    ) async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      await tester.pumpWidget(
        _wrap(
          _gated(TierFeature.castBeyondFreeLimit),
          entitlement: entitlement,
        ),
      );
      expect(
        find.byKey(const ValueKey('tier.absence.castBeyondFreeLimit')),
        findsOneWidget,
      );
      expect(find.textContaining('cast beyond 5 actors'), findsOneWidget);
      entitlement.dispose();
    });

    testWidgets('a dev-override flip rebuilds the gate (watch, not read)', (
      final tester,
    ) async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      await tester.pumpWidget(
        _wrap(_gated(TierFeature.meshSync), entitlement: entitlement),
      );
      expect(find.byKey(_childKey), findsNothing);
      await entitlement.setDevOverride(true);
      await tester.pump();
      expect(find.byKey(_childKey), findsOneWidget);
      entitlement.dispose();
    });
  });
}
