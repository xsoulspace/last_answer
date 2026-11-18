// The SETTINGS ACTORS PANE's retired-visibility law (2026-11-18):
// retirement tombstones the roster, so the pane went silent about
// retired actors — an invisible retirement is a lie of absence. The
// Retired section names them (facts verbatim) with the one-tap Revive
// (the UI face of ADR 0120's revival law); a success moves the actor
// back into the live roster and out of the section. The service is
// REAL over a hermetic world (the repo's lane — a final class is never
// faked), provided above the pane (the pane's own resolution seam:
// `context.read<RealmChatService?>()`).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/actors_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the Retired section names retired actors with the Revive '
      'verb; a success re-adopts the actor into the live list',
      (final tester) async {
    late RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_actors_pane_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      // The retired durable row seeds BEFORE ensureReady: the boot scan
      // names it, never re-adopts it (ADR 0120).
      await world.store.transact(
        (tx) => tx.put('realm_actors', 'toby-researcher', <String, Object?>{
          'actorId': 'toby-researcher',
          'kind': 'realm_actor',
          'displayName': 'Toby Researcher',
          'retiredAt': '2026-11-04T18:16:08.327830Z',
          'retireReason': 'hygiene-sweep',
        }),
      );
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
    });

    // Headroom: the pane is one Column (title, hint, live rows, the
    // mint form, the Retired section) — the section needs the height
    // to be hit-testable.
    await tester.binding.setSurfaceSize(const Size(600, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          // The kit overlay host (same shape as last_answer_app.dart):
          // the kit widgets below need a Portal ancestor.
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: ActorsPanel()),
          ),
        ),
      ),
    );
    await tester.pump();

    // The section, the row and its verbatim facts render; the live
    // roster never adopted the retired identity.
    expect(
      find.byKey(const ValueKey('actors.retired.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('actors.retired.toby-researcher')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('actors.retired.facts.toby-researcher')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('actors.row.toby-researcher')),
      findsNothing,
    );

    // The one-tap Revive: the marks come off the durable row, the
    // actor re-adopts into the live roster, and the section empties
    // (the row's disappearance IS the outcome — no ceremony).
    await tester.tap(
      find.byKey(const ValueKey('actors.revive.toby-researcher')),
    );
    await tester.pump();
    // reviveActor writes the durable world record — real IO, drained
    // inside the test (an unresolved store future poisons the next).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(service.roster!.get('toby-researcher'), isNotNull);
    expect(service.retiredInfo('toby-researcher'), isNull);
    expect(
      find.byKey(const ValueKey('actors.retired.section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('actors.row.toby-researcher')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
