import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_conversation_view.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';

/// LA AS A SEAT, v1: the human sees the world AND what the agents are doing.
///
/// The conversation view today renders the participation RECEIPTS
/// (`agent_participation {op:'events'}`). Agent WORK lives in the world's
/// BEATS — tool results, effects, verification — which the harness serves
/// through the seat-scoped `agent_context {op:'cut'}` surface. This test
/// pins that the view reads the beat stream, and that a lane which does
/// NOT serve it produces an HONEST ABSENCE rather than an empty list that
/// reads as "no work happened".
/// A scripted world: the seat serves exactly what the script says.
final class _World {
  _World({required this.cut});
  final Map<String, Object?> cut;
  final calls = <String>[];

  Future<Map<String, Object?>> invoke(
    String name,
    Map<String, Object?> args,
  ) async {
    calls.add('$name ${args['op']}');
    switch (args['op']) {
      case 'subjects':
        return {
          'ok': true,
          'subjects': [
            {
              'anchor': {'kind': 'task', 'id': _conversation},
              'label': 'My conversation',
            },
          ],
        };
      case 'events':
        return {
          'ok': true,
          'cursor': 0,
          'events': [
            {
              'beat': 'receipt-1',
              'speaker': 'agent-1',
              'text': 'the receipt',
              'anchor': {'kind': 'task', 'id': _conversation},
            },
          ],
        };
      case 'delta':
        return {
          'ok': true,
          'presence': [
            {'actor': 'agent-1'},
          ],
          'frontier': [
            {'title': 'OPEN work', 'ready': true},
          ],
          'claims': [
            {'claim': 'OPEN work', 'claimedBy': 'agent-1'},
          ],
        };
      case 'cut':
        return cut;
    }
    throw StateError('unexpected operation ${args['op']}');
  }
}

const _conversation = 'assignment:human';

void main() {
  Future<void> mount(WidgetTester tester, _World world) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: WorldConversationView(
            binding: const WorldBindingModel(
              worldId: 'test-world',
              endpoint: 'http://localhost/',
            ),
            worldResolver: (_) async => const DiscoveredWorld(
              worldId: 'test-world',
              endpoint: 'http://localhost/',
              source: 'fixture',
              localSeatSocket: '/unused-fixture-socket',
            ),
            seatRequester: (_) async => WorldSeatLease(
              credential: 'fixture-only',
              tools: const {'agent_context', 'agent_participation'},
              actor: 'human',
              invoke: world.invoke,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets("the task's WORK is read from the world's beat stream", (
    tester,
  ) async {
    final world = _World(
      cut: {
        'ok': true,
        'beats': [
          {
            'beatId': 'persistent-beat:7',
            'kind': 'observation',
            'speakerId': 'agent-1',
            'text': 'tool dart_test: 34 passed',
          },
          {
            'beatId': 'persistent-beat:8',
            'kind': 'report',
            'speakerId': 'agent-1',
            'text': 'the task is done',
          },
        ],
      },
    );
    await mount(tester, world);

    // The world's BEATS are shown — the work, not only the receipts.
    expect(
      find.byKey(const Key('world_conversation.work.persistent-beat:7')),
      findsOneWidget,
    );
    expect(
      find.textContaining('34 passed', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('world_conversation.work.persistent-beat:8')),
      findsOneWidget,
    );
    // The receipts still render (the conversation is not replaced).
    expect(
      find.textContaining('the receipt', findRichText: true),
      findsOneWidget,
    );
    // The cut was read through the seat-scoped context surface.
    expect(world.calls, contains('agent_context cut'));

    await unmount(tester);
  });

  testWidgets('a lane that does not serve beats shows an HONEST absence', (
    tester,
  ) async {
    // The remote (WebSocket) lane may not serve the context cut. The pane
    // must say "I could not look" — never an empty list that reads as
    // "no work happened".
    final world = _World(
      cut: {'ok': false, 'bounce': 'seat_capability_denied'},
    );
    await mount(tester, world);

    expect(
      find.byKey(const Key('world_conversation.work.absence')),
      findsOneWidget,
    );
    expect(
      find.textContaining('seat_capability_denied', findRichText: true),
      findsOneWidget,
    );
    // No work rows were invented.
    expect(
      find.byKey(const Key('world_conversation.work.persistent-beat:7')),
      findsNothing,
    );

    await unmount(tester);
  });

  testWidgets('a world that omitted rows says the list is a WINDOW', (
    tester,
  ) async {
    final world = _World(
      cut: {
        'ok': true,
        'beats': [
          {
            'beatId': 'persistent-beat:7',
            'kind': 'observation',
            'text': 'one served row',
          },
        ],
        'omitted': [
          {'reason': 'budget'},
          {'reason': 'rank'},
        ],
      },
    );
    await mount(tester, world);

    expect(
      find.byKey(const Key('world_conversation.work.omitted')),
      findsOneWidget,
    );
    expect(
      find.textContaining('2 more row(s)', findRichText: true),
      findsOneWidget,
    );

    await unmount(tester);
  });
}
