import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';

void main() {
  // Wave 3A — the conversation header's quiet typing indicator
  // (`worldchat.typing`): a static line naming the focused thread's bot
  // while its narration says thinking/generating; absent (no reserved
  // space) otherwise.
  testWidgets(
    'header shows "<name> is thinking…" while the DM bot generates, '
    'nothing when idle',
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

      // Generating: the quiet line names the bot.
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
      expect(tester.widget<Text>(typing).data, 'Toby Researcher is thinking…');

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
}
