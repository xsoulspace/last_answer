// The PEOPLE view's law (WAVE 5 — promoted from the context panel):
// the bot narration line rides each row (`shell.people.status.<id>`),
// humans stay quiet, a listening bot renders nothing — and the focus
// flow (a row tap opens the actor's profile; back returns to the
// list) works through the plain PeopleFocus notifier.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/data_journal/actor_roster.dart';

import 'package:lastanswer/data_journal/realm_bot_host.dart';

import 'package:lastanswer/data_journal/realm_chat_service.dart';

import 'package:lastanswer/data_journal/realm_world.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/ui_shell/shell_theme.dart';

import 'package:lastanswer/ui_shell/view_people.dart';

void main() {
  // Wave 3A — the people view's quiet narration line under each bot row
  // (`shell.people.status.<actorId>`): what the actor is doing right
  // now, with elapsed minutes; humans stay quiet; a listening bot (the
  // normal) renders nothing.
  testWidgets(
    'People view renders the bot narration status line; humans stay '
    'quiet; listening renders nothing',
    (final tester) async {
      // ALL setup rides REAL IO (the kernel store) — inside runAsync,
      // before pumpWidget (the start-begun-in-initState fake-async law).
      late final RealmChatService service;
      late final ActorProfile toby;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_people_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final roster = ActorRoster(replicaId: 'tester');
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: roster,
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        await service.startThread(
          topic: 'Toby Researcher',
          participants: <String>[toby.actorId],
        );
      });

      Widget app() => ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          // The kit overlay host (same shape as last_answer_app.dart):
          // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: ShellTokens.contextColumnWidth,
                  child: PeopleView(service: service),
                ),
              ],
            ),
          ),
        ),
      );

      BotNarration narrationOf(
        final BotNarrationState state, {
        final String? detail,
        final Duration elapsed = Duration.zero,
      }) => BotNarration(
        state: state,
        detail: detail,
        since: DateTime.now().subtract(elapsed),
      );

      final statusLine = find.byKey(
        ValueKey('shell.people.status.${toby.actorId}'),
      );
      final humanLine = find.byKey(
        ValueKey('shell.people.status.${service.humanActorId}'),
      );

      // Generating names the work; elapsed minutes ride along.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(
          BotNarrationState.generating,
          detail: 'lab',
          elapsed: const Duration(minutes: 2),
        ),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(statusLine, findsOneWidget);
      expect(
        tester.widget<Text>(statusLine).data,
        'generating reply to lab · 2m',
      );

      // 3d — the creature layer: a bot's row grows the eyes overlay
      // (`creature.<actorId>` key + Semantics contract), its mood
      // derived from the narration fact (generating → focused); the
      // human row stays a monogram — no creature, no invented state.
      final creature = find.byKey(ValueKey('creature.${toby.actorId}'));
      expect(creature, findsOneWidget);
      expect(
        tester.widget<Semantics>(creature).properties.hint,
        'focused',
      );
      expect(
        find.byKey(ValueKey('creature.${service.humanActorId}')),
        findsNothing,
      );

      // Thinking, idle, echo drop, failure: the one-line narration.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(BotNarrationState.thinking),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(tester.widget<Text>(statusLine).data, 'thinking…');

      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(BotNarrationState.idle),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(tester.widget<Text>(statusLine).data, 'idle');

      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(BotNarrationState.droppedEcho),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(tester.widget<Text>(statusLine).data, 'echo dropped');

      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(
          BotNarrationState.failed,
          detail: 'failed: registration',
        ),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(
        tester.widget<Text>(statusLine).data,
        'failed: registration',
      );
      // The creature's posture follows the same honest fact.
      expect(tester.widget<Semantics>(creature).properties.hint, 'sad');

      // Listening is the quiet normal: no line at all.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: narrationOf(BotNarrationState.listening),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(statusLine, findsNothing);

      // The human participant never carries a status line.
      expect(humanLine, findsNothing);
    },
  );

  testWidgets('a row tap focuses the actor profile through PeopleFocus; '
      'back returns to the plain people list', (final tester) async {
    // ALL setup rides REAL IO (the kernel store) — inside runAsync,
    // or the FakeAsync zone parks the first store await forever.
    late final RealmChatService service;
    late final ActorProfile toby;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_people_focus_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      final roster = ActorRoster(replicaId: 'tester');
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      toby = (await service.createActor(
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: '',
        role: 'researcher',
        systemPrompt: 'You are Toby, a careful researcher.',
      ))!;
      await service.startThread(
        topic: 'Toby Researcher',
        participants: <String>[toby.actorId],
      );
    });

    final focus = PeopleFocus();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          // The kit overlay host (same shape as last_answer_app.dart):
          // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: ShellTokens.contextColumnWidth,
                  child: PeopleView(service: service, focus: focus),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // The plain people list: rows keyed per actor, no profile.
    expect(focus.actorId, isNull);
    expect(
      find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
      findsOneWidget,
    );

    // A row tap focuses the actor: the profile view (keys unchanged
    // from the panel — the agent's UI contract survives the promotion).
    await tester.tap(
      find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
    );
    await tester.pump();
    expect(focus.actorId, toby.actorId);
    expect(find.byKey(const ValueKey('shell.context.actor')), findsOneWidget);
    expect(find.text('You are Toby, a careful researcher.'), findsOneWidget);

    // Back clears the focus.
    await tester.tap(find.byKey(const ValueKey('shell.context.actor.back')));
    await tester.pump();
    expect(focus.actorId, isNull);
    expect(
      find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no active thread still lists the world roster (the '
      'thread-scoped leftover gate hid every actor — reverify 2026-11-17)',
      (final tester) async {
    late final RealmChatService service;
    late final ActorProfile toby;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_people_bare_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      final roster = ActorRoster(replicaId: 'tester');
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      toby = (await service.createActor(
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      // NO startThread: the bare-world state the live shell shows on
      // the landing face.
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: ShellTokens.contextColumnWidth,
                  child: PeopleView(
                    service: service,
                    onOpenConversation: (final surfaceId) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // The roster renders — minted actor AND the human — with the
    // New-actor verb and the row's Message verb; no dead-end note.
    expect(
      find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('shell.context.person.${service.humanActorId}')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('shell.people.newActor')), findsOneWidget);
    expect(
      find.byKey(ValueKey('shell.people.message.${toby.actorId}')),
      findsOneWidget,
    );
    expect(find.text('Select a conversation from the rail.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Retired section names retired actors muted; the tap '
      'opens the actor info (retired visibility, 2026-11-18)',
      (final tester) async {
    late final RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_people_ret_');
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

    var openedActorId = '';
    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: ShellTokens.contextColumnWidth,
                  child: PeopleView(
                    service: service,
                    onOpenActor: (final actorId) => openedActorId = actorId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // The section and its one muted row render; the live people list
    // never adopted the retired identity.
    expect(
      find.byKey(const ValueKey('shell.people.retired')),
      findsOneWidget,
    );
    final row = find.byKey(
      const ValueKey('shell.people.retired.toby-researcher'),
    );
    expect(row, findsOneWidget);
    expect(
      find.byKey(const ValueKey('shell.context.person.toby-researcher')),
      findsNothing,
    );

    // The whole row taps into the actor's INFO surface.
    await tester.tap(row);
    await tester.pump();
    expect(openedActorId, 'toby-researcher');
    expect(tester.takeException(), isNull);
  });

  // THE ACTORS MANAGER (2026-11-18): search, retired toggle, status
  // marks — the world-scoped manager's own contracts.
  group('the actors manager', () {
    Future<(RealmChatService, ActorProfile, ActorProfile)> service0(
      final WidgetTester tester,
    ) async {
      late RealmChatService service;
      late ActorProfile toby;
      late ActorProfile ember;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_manager_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final roster = ActorRoster(replicaId: 'tester');
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: roster,
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        ember = (await service.createActor(
          displayName: 'Ember Scout',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
      });
      return (service, toby, ember);
    }

    Widget app(final RealmChatService service) =>
        ChangeNotifierProvider<RealmChatService>.value(
          value: service,
          child: MaterialApp(
            builder: (final context, final child) =>
                Portal(child: child ?? const SizedBox.shrink()),
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: Row(
                children: [
                  SizedBox(
                    width: ShellTokens.contextColumnWidth,
                    child: PeopleView(service: service),
                  ),
                ],
              ),
            ),
          ),
        );

    testWidgets('the search field filters names case-insensitively and '
        'names the miss', (final tester) async {
      final (service, toby, ember) = await service0(tester);
      await tester.pumpWidget(app(service));
      await tester.pump();

      final tobyRow = find.byKey(
        ValueKey('shell.context.person.${toby.actorId}'),
      );
      final emberRow =
          find.byKey(ValueKey('shell.context.person.${ember.actorId}'));
      expect(tobyRow, findsOneWidget);
      expect(emberRow, findsOneWidget);

      // A name substring narrows the roster.
      await tester.enterText(
        find.byKey(const ValueKey('shell.people.search')),
        'TOBY',
      );
      await tester.pump();
      expect(tobyRow, findsOneWidget);
      expect(emberRow, findsNothing);

      // A miss names itself — never a blank list.
      await tester.enterText(
        find.byKey(const ValueKey('shell.people.search')),
        'zzz-no-one',
      );
      await tester.pump();
      expect(tobyRow, findsNothing);
      expect(emberRow, findsNothing);
      expect(
        find.byKey(const ValueKey('shell.people.search.empty')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('shell.people.search')),
        '',
      );
      await tester.pump();
      expect(tobyRow, findsOneWidget);
      expect(emberRow, findsOneWidget);
    });

    testWidgets('the retired toggle hides and re-shows the retired rows; '
        'the head stays reachable', (final tester) async {
      // Seed one retired durable row BEFORE the boot scan names it and
      // never re-adopts it (the retired-visibility test's pattern).
      late RealmChatService retiredService;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_manager_ret_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        await world.store.transact(
          (tx) => tx.put('realm_actors', 'old-scout', <String, Object?>{
            'actorId': 'old-scout',
            'kind': 'realm_actor',
            'displayName': 'Old Scout',
            'retiredAt': '2026-11-04T18:16:08.327830Z',
            'retireReason': 'hygiene-sweep',
          }),
        );
        retiredService = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(retiredService.dispose);
        await retiredService.ensureReady();
      });
      await tester.pumpWidget(app(retiredService));
      await tester.pump();

      final retiredRow = find.byKey(
        const ValueKey('shell.people.retired.old-scout'),
      );
      final toggle = find.byKey(const ValueKey('shell.people.retired.toggle'));
      // Shown-muted is the default (an invisible retirement is a lie).
      expect(retiredRow, findsOneWidget);

      await tester.tap(toggle);
      await tester.pump();
      expect(retiredRow, findsNothing);
      expect(toggle, findsOneWidget); // the head keeps the re-show verb

      await tester.tap(toggle);
      await tester.pump();
      expect(retiredRow, findsOneWidget);
    });

    testWidgets('the status mark rides the fold: a working bot renders '
        'one, the human never does', (final tester) async {
      final (service, toby, ember) = await service0(tester);
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: BotNarration(
          state: BotNarrationState.generating,
          detail: 'lab',
          since: DateTime.now(),
        ),
      };
      await tester.pumpWidget(app(service));
      await tester.pump();

      expect(
        find.byKey(ValueKey('actor.status.${toby.actorId}')),
        findsOneWidget,
      );
      // The other known bot folds to IDLE (the service's default
      // narration fold keeps a live worker quiet-but-awake); the human
      // never carries a mark.
      expect(
        find.byKey(ValueKey('actor.status.${ember.actorId}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('actor.status.${service.humanActorId}')),
        findsNothing,
      );
    });
  });
}
