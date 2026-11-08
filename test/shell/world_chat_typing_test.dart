import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';

void main() {
  // DESIGN.md v2 — the COMPACT ACTOR HUD's mood mark (`worldchat.typing`):
  // a 6px pulse while the focused thread's bot narration says
  // thinking/generating — the state WORD rides the Semantics label,
  // never header text (the HUD law: identity + mood, nothing else);
  // absent (no reserved space) when idle.
  testWidgets(
    'header pulses with a semantic "<name> is thinking…" while the DM bot '
    'generates, nothing when idle',
    (final tester) async {
      // ALL setup rides REAL IO (the kernel store) — inside runAsync,
      // before pumpWidget (the start-begun-in-initState fake-async law).
      late final RealmChatService service;
      late final ActorProfile toby;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_typing_');
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
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(body: WorldChatSurface(service: service)),
        ),
      );

      final typing = find.byKey(const ValueKey('worldchat.typing'));
      String pulseLabel() {
        final semantics = tester.widget<Semantics>(
          find.descendant(of: typing, matching: find.byType(Semantics)),
        );
        final props = semantics.properties;
        return props.label ?? '';
      }

      // Generating: the pulse carries the state word semantically.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: BotNarration(
          state: BotNarrationState.generating,
          detail: 'Toby Researcher',
          since: DateTime.now(),
        ),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(typing, findsOneWidget);
      expect(pulseLabel(), 'Toby Researcher is thinking…');
      // The HUD law: the status is NOT header text.
      expect(find.text('Toby Researcher is thinking…'), findsNothing);

      // Thinking reads the same way.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: BotNarration(
          state: BotNarrationState.thinking,
          since: DateTime.now(),
        ),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(typing, findsOneWidget);

      // Idle (listening): nothing rendered at all.
      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: BotNarration(
          state: BotNarrationState.listening,
          since: DateTime.now(),
        ),
      };
      await tester.pumpWidget(app());
      await tester.pump();
      expect(typing, findsNothing);
    },
  );

  testWidgets('the card button opens the actor card with the mono facts and '
      'hosts the close affordance', (final tester) async {
    late final RealmChatService service;
    late final ActorProfile toby;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_card_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      toby = (await service.createActor(
        displayName: 'Card Bot',
        kind: ActorKind.model,
        brainRef: 'cast:test-rung',
        role: 'reviewer',
      ))!;
      await service.openDm(toby.actorId);
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(body: WorldChatSurface(service: service)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The facts are NOT in the header line (the HUD law).
    expect(find.text('cast:test-rung'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('worldchat.card')));
    await tester.pump();
    final card = find.byKey(const ValueKey('worldchat.actorCard'));
    expect(card, findsOneWidget);
    // Brain, kind·role and seat are journal facts, one tap away. A
    // `cast:` brainRef is daemon-bound; with no live daemon the seat
    // row says so honestly (the 0f defer law's vocabulary).
    expect(find.text('cast:test-rung'), findsOneWidget);
    expect(find.text('Model · reviewer'), findsOneWidget);
    expect(find.text('daemon-bound · asleep'), findsOneWidget);
    // The close affordance lives in the card (its key survived).
    expect(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('worldchat.close')),
      ),
      findsOneWidget,
    );
  });
}
