import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';

import 'hermetic_world_state.dart';

void main() {
  // 0a/1g — the endless-room scroll law, widget-gated: the tail page
  // renders newest-first, dragging toward the top extent fires the
  // load-older trigger (the row itself lives 300 beats up, where no
  // live semantics walker can reach it — the fmtk smoke WARNs that gap
  // and points HERE), the window walks without losing the reader's
  // place, and the jump pill appears only once the tail is out of
  // sight and returns home in one tap.
  testWidgets('dragging to the top extent walks the window; the jump pill '
      'returns home', (final tester) async {
    late final RealmChatService service;
    late final String threadId;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_tailtrig_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      final toby = (await service.createActor(
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      await service.startThread(
        topic: 'Toby Researcher',
        participants: <String>[toby.actorId],
      );
      threadId = service.activeThreadId!;
      // 300 varied beats, batched — the tail page is 128, so beat 100
      // sits exactly one trigger-load deep.
      final store = world.store;
      for (var batch = 0; batch < 6; batch++) {
        await store.transact((final tx) {
          for (var j = 1; j <= 50; j++) {
            final i = batch * 50 + j;
            tx.put('thread_beats', '$threadId#$i', <String, Object?>{
              'threadId': threadId,
              'beat': i,
              'author': 'human',
              'conversationId': 'lastanswer',
              'text': 'tail trigger beat $i',
              'at': DateTime.now().toUtc().toIso8601String(),
              'addressedTo': const <String>[],
            });
          }
          return null;
        });
      }
      await store.transact((final tx) {
        final row = tx.get('threads', threadId);
        tx.put('threads', threadId, <String, Object?>{
          ...?row,
          'lastBeat': 300,
        });
        return null;
      });
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<WorldStateService>.value(
        value: hermeticWorldState(),
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(body: WorldChatSurface(service: service)),
        ),
      ),
    );
    // The journal watch and every page load are REAL io — fake-time
    // pumps advance nothing. Each settle gets a runAsync gap (the
    // same trap the rail-badge test paid for).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await tester.pump();

    // The tail law, at widget depth: the window is 128 beats, the
    // newest renders, deep history does not.
    expect(service.beats.length, 128);
    expect(find.textContaining('tail trigger beat 300'), findsWidgets);
    expect(find.text('tail trigger beat 1'), findsNothing);
    expect(find.byKey(const ValueKey('worldchat.jumpLatest')), findsNothing);

    // Drive the position directly: the gesture path is framework-
    // owned (and the live fmtk lane cannot scroll a reversed list at
    // all — the smoke WARNs that gap); the PRODUCT law under test is
    // the top-extent trigger, position preservation and the pill.
    // Sample AT the extent, never mid-flight: a 1500px jump skips
    // ~40 rows, so a single deep beat aliases out of the viewport
    // between samples (paid for once, 2026-11-08).
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    var sawPill = false;
    for (var i = 0; i < 30 && service.hasOlderBeats; i++) {
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      sawPill =
          sawPill ||
          tester
              .widgetList(find.byKey(const ValueKey('worldchat.jumpLatest')))
              .isNotEmpty;
    }
    // The trigger fired and the window walked to the journal floor.
    expect(service.hasOlderBeats, isFalse);
    expect(service.beats.length, 300);
    expect(sawPill, isTrue, reason: 'the jump pill never appeared');

    // At the exact top extent the OLDEST beat renders — history is
    // reachable, not frozen — while the tail is out of sight.
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pump();
    expect(find.text('tail trigger beat 1'), findsWidgets);
    expect(find.textContaining('tail trigger beat 300'), findsNothing);
    expect(find.byKey(const ValueKey('worldchat.jumpLatest')), findsOneWidget);

    // One tap returns home to the tail.
    await tester.tap(find.byKey(const ValueKey('worldchat.jumpLatest')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('tail trigger beat 300'), findsWidgets);
    expect(find.byKey(const ValueKey('worldchat.jumpLatest')), findsNothing);
  });
}
