import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';

import 'hermetic_world_state.dart';

void main() {
  // 0b — the inline work texture (the ZCode/Zed law): the room's live
  // work renders IN the stream — a narration row for the loop's cycle
  // state and a work card per task joined by room participation,
  // expandable into the loop's own measured facts (rounds, tool calls,
  // applied writes, cache share, tokens). Nothing is invented: every
  // fact is a journal field.
  testWidgets(
    'the work strip shows the narration row + the room task card and '
    'expands into the loop facts',
    (final tester) async {
      late final RealmChatService service;
      late final ActorProfile toby;
      late final WorldStateService worldState;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_workstrip_');
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
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        await service.startThread(
          topic: 'Toby Researcher',
          participants: <String>[toby.actorId],
        );
        await service.say('What should we ship first?');
      });

      worldState = hermeticWorldState()
        ..debugTasksOverride = <WorldTaskRow>[
          WorldTaskRow(
            taskId: 'task-room',
            state: 'started',
            task: 'fix the frozen-head bug',
            terminal: false,
            modelId: 'modelscope_qwen38max',
            at: '2026-11-07T10:00:00Z',
            addressees: <String>[toby.actorId],
          ),
          // Another room's task — must NOT surface in this stream.
          WorldTaskRow(
            taskId: 'task-elsewhere',
            state: 'started',
            task: 'somewhere else entirely',
            terminal: false,
            at: '2026-11-07T10:00:00Z',
            addressees: const <String>['weaver'],
          ),
        ]
        ..debugTelemetryOverride = <String, ActorTelemetry>{
          toby.actorId: ActorTelemetry(
            actorId: toby.actorId,
            rounds: 4,
            promptTokens: 1000,
            cachedTokens: 840,
            completionTokens: 120,
            toolCalls: 9,
            appliedWrites: 2,
            stalled: false,
            at: '2026-11-07T10:05:00Z',
          ),
        };
      addTearDown(worldState.dispose);

      service.debugNarrationOverride = <String, BotNarration>{
        toby.actorId: BotNarration(
          state: BotNarrationState.generating,
          detail: 'Toby Researcher',
          since: DateTime.now(),
        ),
      };

      Widget app() => ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: ChangeNotifierProvider<WorldStateService>.value(
          value: worldState,
          child: MaterialApp(
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(body: WorldChatSurface(service: service)),
          ),
        ),
      );

      await tester.pumpWidget(app());
      await tester.pump();

      // The in-stream narration row (the header indicator's sibling).
      expect(
        find.byKey(ValueKey('worldchat.narration.${toby.actorId}')),
        findsOneWidget,
      );

      // The work card for THIS room's task — and only this room's.
      expect(
        find.byKey(const ValueKey('worldchat.work.task-room')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('worldchat.work.task-elsewhere')),
        findsNothing,
      );
      expect(find.text('fix the frozen-head bug'), findsOneWidget);
      expect(find.text('started'), findsOneWidget);

      // Collapsed: the loop facts stay folded.
      expect(find.textContaining('9 tools'), findsNothing);

      // Expanded: the loop's own measured facts, all journal fields.
      await tester.tap(
        find.byKey(const ValueKey('worldchat.work.expand.task-room')),
      );
      await tester.pump();
      expect(find.textContaining('4r'), findsOneWidget);
      expect(find.textContaining('9 tools'), findsOneWidget);
      expect(find.textContaining('2 writes'), findsOneWidget);
      expect(find.textContaining('cache 84%'), findsOneWidget);
      expect(find.textContaining('1120 tok'), findsOneWidget);
      expect(find.textContaining('modelscope_qwen38max'), findsOneWidget);
    },
  );

  testWidgets(
    'a quiet room renders no strip at all (no reserved space)',
    (final tester) async {
      late final RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_workstrip_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        await service.startThread(topic: 'quiet room');
        await service.say('just words');
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

      // No narration, no cards — and the beat renders normally.
      expect(find.text('just words'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    },
  );
}
