// ignore_for_file: lines_longer_than_80_chars

// Plan v5 1c — the world binding pick is an IMPLEMENTATION DETAIL:
// the store persists it per doc/workspace key, the inspector view
// auto-resolves it on mount (never a re-pick), an explicit disconnect
// persists as embedded, and an unreachable persisted world degrades to
// embedded WITH an honest quiet note. The widget legs pump the REAL
// registry spec (the world_inspector_surface_test shape) over a real
// loopback facade; the resolver legs run hermetic on a scripted probe.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding_store.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _binding = WorldBindingModel(
  worldId: 'harnessd-persist-test',
  endpoint: 'http://127.0.0.1:59998/',
  displayName: 'persist test world',
);

/// The registry's inspector spec in a bounded Material + l10n tree —
/// the shell tab's own shape (world_inspector_surface_test).
Widget _pumpInspectorTab() => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 800,
        height: 500,
        child: Builder(
          builder: (final context) => Builder(
            builder: buildShellSurfaces(context)[kInspectorSurfaceId]!.builder,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('WorldBindingStore', () {
    test('absent key reads honest absence', () async {
      SharedPreferences.setMockInitialValues({});
      expect(
        await WorldBindingStore.load(docKey: 'doc-1'),
        isA<NoPersistedWorldBinding>(),
      );
    });

    test('saveWorld round-trips the binding JSON under the doc key', () async {
      SharedPreferences.setMockInitialValues({});
      await WorldBindingStore.saveWorld(docKey: 'doc-1', binding: _binding);
      final loaded = await WorldBindingStore.load(docKey: 'doc-1');
      expect(loaded, isA<PersistedExternalWorld>());
      expect((loaded as PersistedExternalWorld).binding, _binding);
      // Keyed by identity: another doc reads absence, not this choice.
      expect(
        await WorldBindingStore.load(docKey: 'doc-2'),
        isA<NoPersistedWorldBinding>(),
      );
    });

    test(
      'an explicit disconnect persists as embedded (never re-attached)',
      () async {
        SharedPreferences.setMockInitialValues({});
        await WorldBindingStore.saveWorld(docKey: 'doc-1', binding: _binding);
        await WorldBindingStore.saveEmbedded(docKey: 'doc-1');
        expect(
          await WorldBindingStore.load(docKey: 'doc-1'),
          isA<PersistedEmbeddedWorld>(),
        );
      },
    );

    test('a corrupt value reads honest absence, never a throw', () async {
      SharedPreferences.setMockInitialValues({
        'lastanswer.world_inspector.binding.v1.doc-1': '{not json',
        'lastanswer.world_inspector.binding.v1.doc-2': jsonEncode({
          'state': 'world',
          'binding': 'not a map',
        }),
      });
      expect(
        await WorldBindingStore.load(docKey: 'doc-1'),
        isA<NoPersistedWorldBinding>(),
      );
      expect(
        await WorldBindingStore.load(docKey: 'doc-2'),
        isA<NoPersistedWorldBinding>(),
      );
    });
  });

  group('resolvePersistedWorldBinding', () {
    test(
      'a reachable persisted world resolves to attach — no re-pick',
      () async {
        SharedPreferences.setMockInitialValues({});
        await WorldBindingStore.saveWorld(docKey: 'doc-1', binding: _binding);
        final resolution = await resolvePersistedWorldBinding(
          docKey: 'doc-1',
          isReachable: (final _) async => true,
        );
        expect(resolution, isA<AttachWorldResolution>());
        expect((resolution as AttachWorldResolution).binding, _binding);
      },
    );

    test(
      'an unreachable persisted world degrades honestly (named, embedded)',
      () async {
        SharedPreferences.setMockInitialValues({});
        await WorldBindingStore.saveWorld(docKey: 'doc-1', binding: _binding);
        final resolution = await resolvePersistedWorldBinding(
          docKey: 'doc-1',
          isReachable: (final _) async => false,
        );
        expect(resolution, isA<UnreachableWorldResolution>());
        expect((resolution as UnreachableWorldResolution).binding, _binding);
      },
    );

    test('absence and explicit disconnect both resolve to embedded', () async {
      SharedPreferences.setMockInitialValues({});
      expect(
        await resolvePersistedWorldBinding(
          docKey: 'doc-1',
          isReachable: (final _) async => true,
        ),
        isA<EmbeddedWorldResolution>(),
      );
      await WorldBindingStore.saveEmbedded(docKey: 'doc-1');
      expect(
        await resolvePersistedWorldBinding(
          docKey: 'doc-1',
          isReachable: (final _) async => true,
        ),
        isA<EmbeddedWorldResolution>(),
      );
    });
  });

  group('the inspector tab auto-resolves', () {
    // The widget legs ride the SCRIPTED reachability seam: `testWidgets`
    // installs a hermetic HTTP override (every client request 400s), so
    // the real facade probe cannot answer here — the transport has its
    // own coverage in world_binding_http_test. What these legs pin is
    // the embed's law: auto-attach, honest degrade, persisted disconnect.
    testWidgets('persist → remount auto-attaches without a user pick', (
      final tester,
    ) async {
      WorldInspectorPane.lastProjection = null;
      SharedPreferences.setMockInitialValues({});
      debugReachabilityOverride = (final b) async =>
          b.worldId == _binding.worldId;
      addTearDown(() => debugReachabilityOverride = null);
      await tester.runAsync(
        () => WorldBindingStore.saveWorld(
          docKey: kInspectorSurfaceId,
          binding: _binding,
        ),
      );

      await tester.pumpWidget(_pumpInspectorTab());
      // Let the mount-time resolution land on the real event loop.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Auto-attached: the rule names the persisted world — no connect
      // tap, no sheet, no pick.
      expect(find.textContaining('WORLD · PERSIST TEST WORLD'), findsOneWidget);
      expect(find.byKey(const Key('world_inspector.degraded')), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('an unreachable persisted binding degrades to embedded '
        'and says so', (final tester) async {
      WorldInspectorPane.lastProjection = null;
      SharedPreferences.setMockInitialValues({});
      debugReachabilityOverride = (final _) async => false;
      addTearDown(() => debugReachabilityOverride = null);
      await tester.runAsync(
        () => WorldBindingStore.saveWorld(
          docKey: kInspectorSurfaceId,
          binding: const WorldBindingModel(
            worldId: 'harnessd-gone',
            endpoint: 'http://127.0.0.1:1/',
            displayName: 'gone world',
          ),
        ),
      );

      await tester.pumpWidget(_pumpInspectorTab());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Embedded, honestly: the degrade note names the lost world and
      // the arm command; the rule does NOT claim the dead world.
      final note = find.byKey(const Key('world_inspector.degraded'));
      expect(note, findsOneWidget);
      expect(
        tester.widget<Text>(note).data,
        allOf(
          contains('gone world'),
          contains('unreachable'),
          contains('embedded world'),
          contains('ecsaid --serve'),
        ),
      );
      expect(find.textContaining('WORLD · GONE WORLD'), findsNothing);
      // The pane runs the embedded path (the shared registry — empty in
      // the test binding), never a crash and never a silent lie.
      final projection = WorldInspectorPane.lastProjection;
      expect(projection, isNotNull);
      expect(projection!.sessions, isEmpty);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('disconnect persists embedded — remount stays embedded', (
      final tester,
    ) async {
      WorldInspectorPane.lastProjection = null;
      SharedPreferences.setMockInitialValues({});
      debugReachabilityOverride = (final b) async =>
          b.worldId == _binding.worldId;
      addTearDown(() => debugReachabilityOverride = null);
      await tester.runAsync(
        () => WorldBindingStore.saveWorld(
          docKey: kInspectorSurfaceId,
          binding: _binding,
        ),
      );

      await tester.pumpWidget(_pumpInspectorTab());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      expect(find.textContaining('WORLD · PERSIST TEST WORLD'), findsOneWidget);

      // The explicit disconnect through the ONE connect surface: pick
      // the embedded row (discovery runs real I/O — flush it).
      await tester.tap(find.byKey(const Key('world_inspector.connect')));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pumpAndSettle();
      // The embedded row (locale-independent: its home-work icon — the
      // sheet's first, default-path row).
      await tester.tap(find.widgetWithIcon(ListTile, Icons.home_work_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The choice persisted as the explicit embedded state.
      final stored = await WorldBindingStore.load(docKey: kInspectorSurfaceId);
      expect(stored, isA<PersistedEmbeddedWorld>());

      // Remount: the persisted disconnect holds — embedded, no note,
      // no re-attach of the previous world.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(_pumpInspectorTab());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('WORLD · PERSIST TEST WORLD'), findsNothing);
      expect(find.byKey(const Key('world_inspector.degraded')), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });
  });
}
