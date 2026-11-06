import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/view_threads.dart';

/// Phase 3b — the Threads view: the threads the rail cannot name, as a
/// read-only projection of the realm list; a click hands the thread to
/// the Conversations view.
void main() {
  testWidgets('world threads render with their last word; a click opens '
      'the thread through the callback', (final tester) async {
    late RealmChatService service;
    late String threadA;
    late String threadB;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_threads_');
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      await service.startThread(topic: 'Design the threads view');
      threadA = service.activeThreadId!;
      await service.say('the first word');
      await service.startThread(topic: 'A plain group thread');
      threadB = service.activeThreadId!;
    });

    final opened = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ThreadsView(service: service, onOpenThread: opened.add),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(ValueKey('threads.row.$threadA')), findsOneWidget);
    expect(find.byKey(ValueKey('threads.row.$threadB')), findsOneWidget);
    expect(find.text('Design the threads view'), findsOneWidget);
    // The last word rides the row's quiet second line.
    expect(find.textContaining('the first word'), findsOneWidget);
    // No live sessions in a hermetic run: the section stays absent.
    expect(find.text('Live sessions'), findsNothing);

    await tester.tap(find.byKey(ValueKey('threads.row.$threadB')));
    await tester.pump();
    expect(opened, [threadB]);
  });

  testWidgets('an empty world says so quietly', (final tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: const Scaffold(
          body: ThreadsView(service: null, onOpenThread: _noop),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('threads.empty')), findsOneWidget);
  });
}

void _noop(final String id) {}
