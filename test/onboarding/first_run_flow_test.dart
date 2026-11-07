// The first-run law (product law, plan v5): everything starts from an
// actor and a conversation. A brand-new user lands in the first-run flow
// INSTEAD of the empty shell; creating the first actor mints it through
// the ONE creation mechanism (RealmChatService.createActor — roster +
// durable realm_actors row), opens the DM, and seeds ONE greeting beat
// under the ACTOR's identity; skip lands in the shell with no actor;
// the persisted completion flag means the second run never shows the
// flow again.
//
// World pattern: the hermetic lane over `RealmWorld.open(rootOverride:)`
// + `RealmChatService(debugWorldOverride:…, debugRosterOverride:…,
// debugStartBotDispatcher: false)` — the established pattern from
// test/coding_agent/realm_chat_tail_paging_test.dart and
// test/shell/app_shell_test.dart.
import 'dart:convert' show jsonEncode;

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/onboarding/first_run_screen.dart';
import 'package:lastanswer/shell/app_shell.dart' show kViewLayoutPrefsKey;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart'
    show LocalDbI;

typedef _Harness = ({
  BuildContext context,
  GoRouter router,
  RealmChatService service,
  RealmWorld world,
});

/// The shell suite's settle law: fixed pumps, never `pumpAndSettle` —
/// the production DI composition carries animation/timer frames that
/// never settle under fake async.
Future<void> _settle(final WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

/// Pumps the first-run flow inside the production DI composition
/// ([GlobalStatesProvider] — PrefsDb rides the mocked SharedPreferences)
/// over a test router with the three production paths: `/` (bootstrap),
/// `/intro` (the flow), `/home` (a marker standing in for the shell).
Future<_Harness> _pumpFirstRun(
  final WidgetTester tester, {
  final String initialLocation = '/intro',
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  // createTempSync, never an awaited createTemp here: a real-IO await in
  // the fake-async zone never settles (the shell suite's createTempSync
  // law).
  final temp = Directory.systemTemp.createTempSync('la_firstrun_');
  addTearDown(() => temp.deleteSync(recursive: true));
  // Pin the realm device root so no palette/health walk reads the real
  // machine's ~/.xsoulspace (the shell suite's law).
  RealmWorld.debugDeviceHome = temp.path;
  addTearDown(() => RealmWorld.debugDeviceHome = null);
  late RealmWorld world;
  late RealmChatService service;
  // Real-async world start BEFORE any widget pumps (the app_shell_test
  // law: a start begun in the fake-async zone never settles).
  await tester.runAsync(() async {
    world = (await RealmWorld.open(rootOverride: temp.path))!;
    service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    await service.ensureReady();
  });
  addTearDown(service.dispose);
  late BuildContext captured;
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            const Scaffold(body: Text('bootstrap', key: ValueKey('test.boot'))),
      ),
      GoRoute(
        path: '/intro',
        builder:
            (_, _) => Scaffold(
              body: FirstRunScreen(
                service: service,
                // The palette-rung grammar exactly as availableBrainOptions
                // composes it: `cast:<entryId>`.
                brainOptions: const [
                  (ref: 'cast:test-rung', label: 'Palette · test-rung'),
                ],
              ),
            ),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) =>
            const Scaffold(body: Text('home', key: ValueKey('test.home'))),
      ),
    ],
  );
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final context) {
        captured = context;
        return MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          routerConfig: router,
        );
      },
    ),
  );
  await _settle(tester);
  // The boot law's storage step: PrefsDb must be initialized before any
  // user persistence rides it (GlobalStatesInitializer.onLoad does this).
  // The mocked SharedPreferences answers in the fake zone (the shell
  // suite's own getInstance law).
  await captured.read<LocalDbI>().init();
  return (context: captured, router: router, service: service, world: world);
}

void main() {
  group('the brain-option grammar', () {
    test('palette rungs are offered as cast:<entryId>', () {
      final options = availableBrainOptions(
        defaultOpenRouterModel: '',
        discoverQwen3Variants: () => const [],
        paletteRungs: const [
          CastBrainDecl(
            id: 'test-rung',
            model: 'test-model',
            transport: 'openai_compatible',
          ),
        ],
      );
      expect(options.map((final o) => o.ref), contains('cast:test-rung'));
    });
  });

  group('the first-run routing branch', () {
    testWidgets('a fresh user routes to the flow, a returning user to home', (
      final tester,
    ) async {
      final h = await _pumpFirstRun(tester, initialLocation: '/');

      // First run: the flag is false → the flow, never the empty shell.
      final fresh = await tester.runAsync(
        () => UserRepository(h.context).getLocalUser(),
      );
      expect(fresh!.hasCompletedOnboarding, isFalse);
      GlobalStatesInitializer.routeAfterLoad(
        h.router,
        hasCompletedOnboarding: fresh.hasCompletedOnboarding,
      );
      await _settle(tester);
      expect(find.byType(FirstRunScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('test.home')), findsNothing);

      // Returning user: home, and the flow is never shown again.
      GlobalStatesInitializer.routeAfterLoad(
        h.router,
        hasCompletedOnboarding: true,
      );
      await _settle(tester);
      expect(find.byType(FirstRunScreen), findsNothing);
      expect(find.byKey(const ValueKey('test.home')), findsOneWidget);
    });
  });

  group('creating the first actor', () {
    testWidgets(
      'lands in the DM with ONE greeting beat under the actor authorship',
      (final tester) async {
        final h = await _pumpFirstRun(tester);
        await tester.enterText(
          find.byKey(const ValueKey('firstrun.name')),
          'Toby',
        );
        await tester.enterText(
          find.byKey(const ValueKey('firstrun.persona')),
          'A calm research companion.',
        );
        await tester.pump();
        final expectedGreeting = S.of(
          tester.element(find.byType(FirstRunScreen)),
        ).firstRunGreeting('Toby');

        Map<String, Object?>? greetingBeat;
        String? threadId;
        await tester.ensureVisible(
          find.byKey(const ValueKey('firstrun.create')),
        );
        await tester.pump();
        await tester.runAsync(() async {
          await tester.tap(find.byKey(const ValueKey('firstrun.create')));
          // Wait for the whole completion sequence: the greeting beat in
          // the durable plane, the DM selected, onboarding done.
          final deadline = DateTime.now().add(const Duration(seconds: 45));
          while (true) {
            final active = h.service.activeThreadId;
            final done =
                h.context.read<UserNotifier>().hasCompletedOnboarding;
            if (active != null && done) {
              final beats = await h.world.projection.beatsOfThread(active);
              final found = beats
                  .where((final b) => b['text'] == expectedGreeting)
                  .toList();
              if (found.isNotEmpty) {
                threadId = active;
                greetingBeat = found.first;
                break;
              }
            }
            if (DateTime.now().isAfter(deadline)) {
              fail(
                'the flow never completed (active: $active, done: $done, '
                'beat: ${greetingBeat != null})',
              );
            }
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
        });
        await _settle(tester);

        // The actor: minted through the ONE mechanism, `cast:` brain and
        // persona intact, and the greeting is ITS beat, not the human's.
        final actor = h.service.roster!.all.firstWhere(
          (final a) => a.kind != ActorKind.human,
        );
        expect(actor.displayName, 'Toby');
        expect(actor.brainRef, 'cast:test-rung');
        expect(actor.systemPrompt, 'A calm research companion.');
        expect(greetingBeat!['author'], actor.actorId);
        expect(greetingBeat!['author'], isNot(h.service.humanActorId));

        // The durable realm row exists (the world record IS identity).
        final records = await tester.runAsync(
          () => h.world.store.scan('realm_actors'),
        );
        expect(records![actor.actorId]?['brainRef'], 'cast:test-rung');

        // Landed home, in the DM: the thread is the two-member DM, it is
        // the selected thread, and the shell's persisted layout opens its
        // conversation tab on boot.
        expect(find.byKey(const ValueKey('test.home')), findsOneWidget);
        expect(h.service.dmThreadOf(actor.actorId), threadId);
        expect(h.service.activeThreadId, threadId);
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString(kViewLayoutPrefsKey),
          contains('dm:${actor.actorId}'),
        );

        // Exactly ONE beat was seeded — the room is not empty, not noisy.
        final beats = await tester.runAsync(
          () => h.world.projection.beatsOfThread(threadId!),
        );
        expect(beats, hasLength(1));

        // The completion flag persisted: the second run reads it.
        final reloaded = await tester.runAsync(
          () => UserRepository(h.context).getLocalUser(),
        );
        expect(reloaded!.hasCompletedOnboarding, isTrue);
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );
  });

  group('the calm skip', () {
    testWidgets('lands in the shell with no actor, flag persisted', (
      final tester,
    ) async {
      final h = await _pumpFirstRun(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('firstrun.skip')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('firstrun.skip')));
      await _settle(tester);

      // Home, no actor minted, no brain faked.
      expect(find.byKey(const ValueKey('test.home')), findsOneWidget);
      expect(find.byType(FirstRunScreen), findsNothing);
      expect(
        h.service.roster!.all.where((final a) => a.kind != ActorKind.human),
        isEmpty,
      );
      expect(h.context.read<UserNotifier>().hasCompletedOnboarding, isTrue);

      // The flag persisted through the repository (unawaited write —
      // give the real zone a beat to flush it).
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      final reloaded = await tester.runAsync(
        () => UserRepository(h.context).getLocalUser(),
      );
      expect(reloaded!.hasCompletedOnboarding, isTrue);
    });
  });

  group('the second launch', () {
    testWidgets('boots straight to home — the flow is never shown again', (
      final tester,
    ) async {
      // The persisted state a completed first run leaves behind, written
      // in the repository's own shape (PrefsDb stores the user JSON map
      // under the `user` key).
      SharedPreferences.setMockInitialValues(<String, Object>{
        'user': jsonEncode(
          const UserModel(hasCompletedOnboarding: true).toJson(),
        ),
      });
      late BuildContext captured;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder:
                (_, _) => const Scaffold(
                  body: Text('bootstrap', key: ValueKey('test.boot2')),
                ),
          ),
          GoRoute(
            path: '/intro',
            builder:
                (_, _) => const Scaffold(
                  body: FirstRunScreen(brainOptions: []),
                ),
          ),
          GoRoute(
            path: '/home',
            builder:
                (_, _) => const Scaffold(
                  body: Text('home', key: ValueKey('test.home2')),
                ),
          ),
        ],
      );
      await tester.pumpWidget(
        GlobalStatesProvider(
          builder: (final context) {
            captured = context;
            return MaterialApp.router(
              locale: const Locale('en'),
              localizationsDelegates: S.localizationsDelegates,
              supportedLocales: S.supportedLocales,
              routerConfig: router,
            );
          },
        ),
      );
      await _settle(tester);
      await captured.read<LocalDbI>().init();

      // The boot decision reads the STORED user, exactly like the
      // initializer's onLoad does before routing.
      final returning = await tester.runAsync(
        () => UserRepository(captured).getLocalUser(),
      );
      expect(returning!.hasCompletedOnboarding, isTrue);
      GlobalStatesInitializer.routeAfterLoad(
        router,
        hasCompletedOnboarding: returning.hasCompletedOnboarding,
      );
      await _settle(tester);
      expect(find.byType(FirstRunScreen), findsNothing);
      expect(find.byKey(const ValueKey('test.home2')), findsOneWidget);
    });
  });
}
