// The pinned-conversation peek (ADR 0027): the read-only miniwindow
// surface upgraded to a live beat column — read on mount, on every
// service notification, and on a 2s timer while mounted (dispose
// cancels it; flutter_test fails any test that ends with the periodic
// timer still pending, so the whole suite polices that law).
//
// Real store IO inside `tester.runAsync` bodies — never fake-async
// (the actor_identity_editing_test / app_shell_test pattern).


import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/pinned_conversation_peek.dart';

/// One hermetic peek fixture: a disposable world, a service over it,
/// and the DM thread the peek watches.
final class _PeekFixture {
  _PeekFixture({
    required this.world,
    required this.service,
    required this.threadId,
  });

  final RealmWorld world;
  final RealmChatService service;
  final String threadId;
}

Future<_PeekFixture> _hermeticPeek() async {
  final temp = await Directory.systemTemp.createTemp('la_peek_');
  addTearDown(() => temp.delete(recursive: true));
  final world = (await RealmWorld.open(rootOverride: temp.path))!;
  final service = RealmChatService(
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
    role: 'researcher',
  ))!;
  await service.startThread(
    topic: 'Peek topic',
    participants: <String>[toby.actorId],
  );
  return _PeekFixture(
    world: world,
    service: service,
    threadId: service.activeThreadId!,
  );
}

/// Flushes real IO behind the fake-async pumps: pumps and runAsync
/// take turns until [finder] matches (or ~4s pass).
Future<void> _pumpUntil(
  final WidgetTester tester,
  final Finder finder,
) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 80 && !tester.any(finder); i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  });
}

Widget _host(final RealmChatService service, final String threadId) =>
    MaterialApp(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 280,
          child: PinnedConversationPeek(service: service, threadId: threadId),
        ),
      ),
    );

void main() {
  testWidgets('renders the recent beats with quiet authorship',
      (final tester) async {
    late final _PeekFixture peek;
    await tester.runAsync(() async {
      peek = await _hermeticPeek();
      await peek.service.say('first beat');
      await peek.service.say('second beat');
    });

    await tester.pumpWidget(_host(peek.service, peek.threadId));
    // The mount read rides real IO.
    await _pumpUntil(tester, find.text('second beat'));

    expect(find.text('first beat'), findsOneWidget);
    expect(find.text('second beat'), findsOneWidget);
    // Beats keyed per number (the agent's UI contract, DESIGN §6).
    expect(
      find.byKey(ValueKey('miniwindow.peek.${peek.threadId}.beat.1')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('miniwindow.peek.${peek.threadId}.beat.2')),
      findsOneWidget,
    );
    // The header keeps topic + participants (roster names).
    expect(find.text('Peek topic'), findsOneWidget);
    expect(find.textContaining('Toby Researcher'), findsWidgets);
    // The human's roster-less id (`human-<digits>`) reads as 'Human'.
    expect(find.text('Human'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the 2s poll picks up a beat nobody announced',
      (final tester) async {
    late final _PeekFixture peek;
    await tester.runAsync(() async {
      peek = await _hermeticPeek();
    });

    await tester.pumpWidget(_host(peek.service, peek.threadId));
    await tester.pump();

    // Say through the kernel directly: the service never notifies, so
    // only the periodic timer can deliver this beat.
    await tester.runAsync(
      () => peek.world.conversation().say(
            actor: peek.world.authorityFor(peek.service.humanActorId!),
            threadId: peek.threadId,
            text: 'quiet beat',
          ),
    );
    await tester.pump(const Duration(seconds: 2));
    await _pumpUntil(tester, find.text('quiet beat'));

    expect(find.text('quiet beat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unknown thread renders the quiet empty note',
      (final tester) async {
    late final _PeekFixture peek;
    await tester.runAsync(() async {
      peek = await _hermeticPeek();
    });

    await tester.pumpWidget(_host(peek.service, 'no-such-thread'));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('miniwindow.peek.no-such-thread')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
