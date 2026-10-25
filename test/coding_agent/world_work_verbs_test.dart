import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_model_picker.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_work_verbs.dart';

/// LA AS A SEAT, v2: the human can make the world WORK.
///
/// The conversation surface already spoke (`message`) and listened
/// (`events`/`delta`). These pin the three WORK verbs — `resource_bind`,
/// `task_delegate`, `tool_action` — and the palette read that feeds them:
/// the world is the ONLY source of models, and a refusal is the harness's
/// own bounce code, verbatim.
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
    test(
      'resource_bind binds THIS seat on its own assignment thread',
      () async {
        final world = _World()
          ..responses['actions'] = _actions()
          ..responses['resource_bind'] = {'ok': true};
        final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
        await seat.load();

        final receipt = await seat.bind(
          purpose: 'generative',
          modelId: 'openrouter_minimax',
        );

        expect(receipt.ok, isTrue);
        final call = world.calls.last;
        expect(call['op'], 'resource_bind');
        expect(call['modelId'], 'openrouter_minimax');
        expect(call['thread'], 'assignment:human-1');
        // The actor is the seat's own identity — never a parameter.
        expect(call.containsKey('actor'), isFalse);
      },
    );

    test('a refusal is the harness bounce code, verbatim', () async {
      final world = _World()
        ..responses['actions'] = _actions()
        ..responses['resource_bind'] = {
          'ok': false,
          'bounce': 'model_not_in_palette',
        };
      final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
      await seat.load();

      final receipt = await seat.bind(
        purpose: 'generative',
        modelId: 'laya_local',
      );

      expect(receipt.ok, isFalse);
      expect(receipt.bounce, 'model_not_in_palette');
      expect(receipt.label, 'resource_bind · model_not_in_palette');
    });

    test(
      'a coding delegate never carries a model; a decision one does',
      () async {
        final world = _World()
          ..responses['actions'] = _actions()
          ..responses['task_delegate'] = {'ok': true};
        final seat = WorldWorkSeat(actor: 'human-1', invoke: world.invoke);
        await seat.load();

        await seat.delegate(
          task: 'write the note',
          // `coding` is the default AND the case under test: a coding
          // purpose must never carry a model.
          // ignore: avoid_redundant_argument_values
          purpose: 'coding',
          modelId: 'laya_local',
        );
        expect(world.calls.last['purpose'], 'coding');
        expect(world.calls.last.containsKey('modelId'), isFalse);

        await seat.delegate(
          task: 'write the note',
          purpose: 'decision',
          modelId: 'laya_local',
        );
        expect(world.calls.last['purpose'], 'decision');
        expect(world.calls.last['modelId'], 'laya_local');
        expect(world.calls.last['requestId'], isNotNull);
      },
    );

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
