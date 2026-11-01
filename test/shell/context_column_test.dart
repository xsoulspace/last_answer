import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/context_column.dart';
import 'package:lastanswer/shell/shell_theme.dart';

void main() {
  // Wave 3A — the People tab's quiet narration line under each bot row
  // (`shell.people.status.<actorId>`): what the actor is doing right
  // now, with elapsed minutes; humans stay quiet; a listening bot (the
  // normal) renders nothing.
  testWidgets(
    'People tab renders the bot narration status line; humans stay '
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
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: ShellTokens.contextColumnWidth,
                  child: ShellContextColumn(service: service),
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
}
