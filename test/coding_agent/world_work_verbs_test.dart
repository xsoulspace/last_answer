import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_model_picker.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_work_verbs.dart';

/// LA AS A SEAT, v3 (ADR 0118): the human can make the world WORK.
///
/// The conversation surface already spoke (`message`) and listened
/// (`events`/`delta`). These pin the CURRENT work verbs — `task
/// op:create/show/say` (delegation is not a verb: creation IS the
/// delegation), `actor_bind` and `tool_action` — and the palette read
/// that feeds them: the world is the ONLY source of models, and a
/// refusal is the harness's own bounce code, verbatim. The retired
/// pre-0118 verbs (`resource_bind`, `task_delegate`) must never appear
/// on the wire again (leg B G4).
final class _World {
  final responses = <String, Map<String, Object?>>{};
  final calls = <Map<String, Object?>>[];

  Future<Map<String, Object?>> invoke(
    final String name,
    final Map<String, Object?> args,
  ) async {
    calls.add({'name': name, ...args});
    final response = responses['${args['op']}'];
    if (response == null) throw StateError('unexpected ${args['op']}');
    return response;
  }
}

const _palette = {
  'entries': [
    {
      'id': 'openrouter_minimax',
      'kind': 'generative',
      'model': 'minimax/minimax-m3.1-flash:free',
      'provider': 'openrouter',
      'primary': true,
      'capabilities': ['text'],
      'bound': true,
    },
    {
      'id': 'laya_local',
      'kind': 'decision',
      'model': 'laya-1',
      'provider': 'local',
      'primary': false,
      'capabilities': <String>[],
      'bound': false,
    },
  ],
  'roles': {'generative': 'openrouter_minimax', 'decision': 'laya_local'},
};

Map<String, Object?> _actions({
  final String revision = 'rev-7',
  final String tool = 'repo_etl',
}) => {
  'ok': true,
  'modelPalette': _palette,
  'toolMenu': {
    'revision': revision,
    'tools': [
      {'name': tool, 'summary': 'scan the workspace'},
    ],
  },
};

void main() {
  group('the palette is READ, never hardcoded', () {
    test('entries, roles and bound state come from the actions read', () async {
      final world = _World()..responses['actions'] = _actions();
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);

      await seat.load();

      expect(seat.palette.entries.map((final entry) => entry.id), [
        'openrouter_minimax',
        'laya_local',
      ]);
      expect(
        seat.palette.entryForRole('generative')!.model,
        'minimax/minimax-m3.1-flash:free',
      );
      // An entry the world has not bound is DATA, not something to hide.
      expect(seat.palette.entryById('laya_local')!.bound, isFalse);
      expect(seat.toolMenuRevision, 'rev-7');
      expect(seat.tools.single.name, 'repo_etl');
      expect(world.calls.single['op'], 'actions');
    });

    test('an empty palette is an honest empty, not a default model', () async {
      final world = _World()
        ..responses['actions'] = {
          'ok': true,
          'modelPalette': {
            'entries': <Object?>[],
            'roles': <String, Object?>{},
          },
          'toolMenu': {'revision': 'rev-1', 'tools': <Object?>[]},
        };
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);

      await seat.load();

      expect(seat.palette.isEmpty, isTrue);
      expect(seat.paletteAbsence, isNull);
      expect(seat.palette.entries, isEmpty);
    });

    test('a lane that refuses actions names the bounce', () async {
      final world = _World()
        ..responses['actions'] = {
          'ok': false,
          'bounce': 'seat_capability_denied',
        };
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);

      await seat.load();

      expect(seat.palette.isEmpty, isTrue);
      expect(seat.paletteAbsence, 'seat_capability_denied');
      expect(seat.toolMenuRevision, isNull);
    });

    test('a changed toolMenu revision replaces the cached menu', () async {
      final world = _World()..responses['actions'] = _actions();
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();
      expect(seat.toolMenuRevision, 'rev-7');

      world.responses['actions'] = _actions(revision: 'rev-8', tool: 'other');
      await seat.load(force: true);

      expect(seat.toolMenuRevision, 'rev-8');
      expect(seat.tools.single.name, 'other');
    });
  });

  group('the work verbs', () {
    test("actor_bind binds THIS seat's own actor row", () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['actor_bind'] = {'ok': true};
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final receipt = await seat.bindCast(brainCast: 'openrouter_minimax');

      expect(receipt.ok, isTrue);
      final call = world.calls.last;
      expect(call['name'], 'agent_participation');
      expect(call['op'], 'actor_bind');
      expect(call['brainCast'], 'openrouter_minimax');
      // The actor is the seat's own identity — never another actor's.
      expect(call['actorId'], 'human-1');
    });

    test('a refusal is the harness bounce code, verbatim', () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['actor_bind'] = {
          'ok': false,
          'bounce': 'model_not_in_palette',
        };
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final receipt = await seat.bindCast(brainCast: 'laya_local');

      expect(receipt.ok, isFalse);
      expect(receipt.bounce, 'model_not_in_palette');
      expect(receipt.label, 'actor_bind · model_not_in_palette');
    });

    test(
      'a delegate rides task op:create; the picked rung rides modelId',
      () async {
        final world = _World()
          ..responses['actions'] = _actions()
          ..responses['create'] = {
            'ok': true,
            'taskId': 'task-1',
            'admissionBeatId': 'control:task:task-1',
            'state': 'queued',
          };
        final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
        await seat.load();

        // Under ADR 0118 the modelId is legal for ANY purpose — the
        // pre-0118 "coding never carries a model" rule retired with
        // `decision_purpose_required` (leg B G3).
        final receipt = await seat.delegate(
          task: 'write the note',
          // ignore: avoid_redundant_argument_values
          purpose: 'coding',
          modelId: 'openrouter_minimax',
        );
        expect(receipt.ok, isTrue);
        // The admission is NOT a completion — the receipt says queued.
        expect(receipt.result['state'], 'queued');
        expect(world.calls.last['name'], 'task');
        expect(world.calls.last['op'], 'create');
        expect(world.calls.last['modelId'], 'openrouter_minimax');

        await seat.delegate(
          task: 'judge the note',
          purpose: 'decision',
          modelId: 'laya_local',
          addressees: const ['scout'],
        );
        expect(world.calls.last['purpose'], 'decision');
        expect(world.calls.last['modelId'], 'laya_local');
        expect(world.calls.last['addressees'], ['scout']);
        expect(world.calls.last['requestId'], isNotNull);
      },
    );

    test('an identical FAILED delegate retries on one request id', () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['create'] = {'ok': false, 'bounce': 'queue_full'};
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      await seat.delegate(task: 'write the note');
      final first = world.calls.last['requestId'];
      await seat.delegate(task: 'write the note');
      // The host dedupes exact retries: same sentence, same id.
      expect(world.calls.last['requestId'], first);

      await seat.delegate(task: 'a different sentence');
      expect(world.calls.last['requestId'], isNot(first));
    });

    test('task show/say ride the same task tool', () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['show'] = {
          'ok': true,
          'state': 'succeeded',
          'terminal': {
            'state': 'succeeded',
            'result': {'summary': 'the note is written'},
          },
        }
        ..responses['say'] = {'ok': true};
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final shown = await seat.taskState(taskId: 'task-1');
      expect(shown.ok, isTrue);
      expect(world.calls.last['name'], 'task');
      expect(world.calls.last['taskId'], 'task-1');

      final said = await seat.taskSay(taskId: 'task-1', text: 'again, please');
      expect(said.ok, isTrue);
      expect(world.calls.last['op'], 'say');
      expect(world.calls.last['text'], 'again, please');
    });

    test('tool_action echoes the menu revision it just read', () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['tool_action'] = {'ok': true};
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final receipt = await seat.toolAction(toolName: 'repo_etl');

      expect(receipt.ok, isTrue);
      final call = world.calls.last;
      expect(call['op'], 'tool_action');
      expect(call['toolName'], 'repo_etl');
      expect(call['toolRevision'], 'rev-7');
      expect(call['thread'], 'assignment:human-1');
    });

    test('tool_action without a revision refuses honestly', () async {
      final world = _World()
        ..responses['actions'] = {
          'ok': true,
          'modelPalette': {
            'entries': <Object?>[],
            'roles': <String, Object?>{},
          },
        };
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final receipt = await seat.toolAction(toolName: 'repo_etl');

      expect(receipt.ok, isFalse);
      expect(receipt.bounce, 'tool_menu_unavailable');
      // Nothing was sent: a call without a revision is not a call.
      expect(
        world.calls.where((final call) => call['op'] == 'tool_action'),
        isEmpty,
      );
    });
  });

  group('the picker', () {
    Future<void> mount(
      final WidgetTester tester, {
      required final WorldModelPalette palette,
      final String? absence,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldModelPicker(
              palette: palette,
              absence: absence,
              purpose: 'coding',
              selectedId: 'openrouter_minimax',
              onPurpose: (_) {},
              onSelect: (_) {},
              onBind: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders the world palette as grid rows', (final tester) async {
      await mount(tester, palette: WorldModelPalette.fromJson(_palette));

      expect(
        find.byKey(
          const Key('coding_agent.world.model.entry.openrouter_minimax'),
        ),
        findsOneWidget,
      );
      expect(find.text('minimax/minimax-m3.1-flash:free'), findsOneWidget);
      // The unbound entry is SHOWN, with its state named.
      expect(
        find.byKey(const Key('coding_agent.world.model.entry.laya_local')),
        findsOneWidget,
      );
      expect(find.textContaining('UNBOUND'), findsOneWidget);
      // The gutter carries the role, not an icon.
      expect(find.text('GEN'), findsOneWidget);
      expect(find.text('DEC'), findsOneWidget);
    });

    testWidgets('an empty palette says so instead of inventing a model', (
      final tester,
    ) async {
      await mount(tester, palette: WorldModelPalette.empty);

      expect(
        find.byKey(const Key('coding_agent.world.model.empty')),
        findsOneWidget,
      );
      expect(
        find.textContaining('no model palette declared for this world'),
        findsOneWidget,
      );
    });

    testWidgets('an unreadable palette names the bounce', (final tester) async {
      await mount(
        tester,
        palette: WorldModelPalette.empty,
        absence: 'seat_capability_denied',
      );

      expect(
        find.byKey(const Key('coding_agent.world.model.absence')),
        findsOneWidget,
      );
      expect(find.textContaining('seat_capability_denied'), findsOneWidget);
    });
  });
}
