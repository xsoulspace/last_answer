import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_conversation_view.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_tools.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_seats.dart';

const _conversation = 'assignment:human';
const _task = 'application-change';

Map<String, Object?> _map(Object? value) =>
    Map<String, Object?>.from(value! as Map);
List<Map<String, Object?>> _rows(Object? value) =>
    (value! as List).map(_map).toList();

/// Fake owner receipts over the existing lease invocation seam; no world grant
/// or native transaction is created by these widget-contract tests.
final class _Owner {
  final messages = <Map<String, Object?>>[];
  bool refuseNext = false;
  String? eventsError;

  Future<Map<String, Object?>> invoke(
    String name,
    Map<String, Object?> args,
  ) async {
    expect(name, 'agent_participation');
    switch (args['op']) {
      case 'subjects':
        return {
          'ok': true,
          'subjects': [
            for (final (id, label) in [
              (_conversation, 'My conversation'),
              (_task, 'Application change'),
            ])
              {
                'anchor': {'kind': 'task', 'id': id},
                'label': label,
              },
          ],
        };
      case 'events':
        if (eventsError case final error?) throw StateError(error);
        return {'ok': true, 'events': <Object?>[], 'cursor': 0};
      case 'message':
        messages.add(
          Map<String, Object?>.from(jsonDecode(jsonEncode(args)) as Map),
        );
        if (refuseNext) {
          refuseNext = false;
          return {'ok': false, 'bounce': 'task_consent_issuer_not_allowed'};
        }
        return {
          'ok': true,
          'interaction': {
            'beat': 'owner-${messages.length}',
            'speaker': 'human',
            'anchor': args['anchor'],
            'text': args['text'],
          },
        };
    }
    throw StateError('unexpected operation ${args['op']}');
  }
}

void main() {
  late _Owner owner;

  Future<void> mount(WidgetTester tester, {Size? size}) async {
    owner = _Owner();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: size?.width,
            height: size?.height,
            child: WorldConversationView(
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
                tools: const {'agent_participation'},
                actor: 'human',
                invoke: owner.invoke,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      WorldConversationView.active!.projection['conversation'],
      _conversation,
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets(
    'a retained view stays addressable after the newer view is removed',
    (tester) async {
      final owner = _Owner();
      Widget view(String id) => WorldConversationView(
        key: ValueKey(id),
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
          tools: const {'agent_participation'},
          actor: 'human',
          invoke: owner.invoke,
        ),
      );
      Widget app({required bool showNewer}) => MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: view('retained-view')),
              if (showNewer) Expanded(child: view('newer-view')),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app(showNewer: true));
      await tester.pumpAndSettle();
      expect(WorldConversationView.currentViewCount, 2);
      expect(WorldConversationView.active, isNull);
      final tool = worldInspectorMcpEntries().singleWhere(
        (entry) => entry.name == 'world_conversation',
      );
      final ambiguous = await tool.invokeDirect({'op': 'state'});
      expect(ambiguous.data['ok'], isFalse);
      expect(ambiguous.data['bounce'], 'world_conversation_ambiguous');
      final retained = tester.state<WorldConversationViewState>(
        find.byKey(const ValueKey('retained-view')),
      );
      await tester.pumpWidget(app(showNewer: false));
      await tester.pumpAndSettle();
      expect(retained.mounted, isTrue);
      expect(WorldConversationView.active, same(retained));
      // Both routes remain mounted, but only the top route is addressable.
      final pushed = Navigator.of(retained.context).push<void>(
        MaterialPageRoute(builder: (_) => Scaffold(body: view('top-route'))),
      );
      await tester.pumpAndSettle();
      final top = tester.state<WorldConversationViewState>(
        find.byKey(const ValueKey('top-route')),
      );
      expect(retained.mounted, isTrue);
      expect(WorldConversationView.mountedViewCount, 2);
      expect(WorldConversationView.currentViewCount, 1);
      expect(WorldConversationView.active, same(top));
      Navigator.of(top.context).pop();
      await tester.pumpAndSettle();
      await pushed;
      expect(WorldConversationView.active, same(retained));
      final reassembled = tester.binding.reassembleApplication();
      await tester.pump();
      await reassembled;
      await tester.pumpAndSettle();
      expect(WorldConversationView.currentViewCount, 1);
      expect(WorldConversationView.active, same(retained));
      await unmount(tester);
      expect(WorldConversationView.mountedViewCount, 0);
    },
  );

  testWidgets(
    'compact world region keeps conversation and permission actions usable',
    (tester) async {
      const size = Size(558, 171.8);
      await mount(tester, size: size);
      expect(tester.takeException(), isNull);
      for (final key in [
        'world_conversation.input',
        'world_conversation.send',
        'world_conversation.consent',
      ]) {
        final rect = tester.getRect(find.byKey(Key(key)));
        expect(rect.right, lessThanOrEqualTo(size.width));
        expect(rect.bottom, lessThanOrEqualTo(size.height));
      }
      owner.eventsError = List.filled(
        20,
        'Temporary owner observation failure.',
      ).join(' ');
      await WorldConversationView.active!.refresh();
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'long errors must scroll without moving controls',
      );
      await tester.tap(find.byKey(const Key('world_conversation.consent')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('world_conversation.consent.cancel')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('world_conversation.input')),
        'Continue the conversation',
      );
      await tester.tap(find.byKey(const Key('world_conversation.send')));
      await tester.pumpAndSettle();
      expect(owner.messages.single['text'], 'Continue the conversation');
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('visible task permission publishes one bounded owner statement', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byKey(const Key('world_conversation.consent')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('world_conversation.consent.task')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Application change').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('world_conversation.consent.actor')),
      'external-actor',
    );
    await tester.enterText(
      find.byKey(const Key('world_conversation.consent.paths')),
      'lib/main.dart\nlib/title.dart',
    );
    await tester.tap(
      find.byKey(const Key('world_conversation.consent.authorize')),
    );
    await tester.pumpAndSettle();

    expect(owner.messages, hasLength(1));
    final statement = owner.messages.single;
    expect(statement['op'], 'message');
    expect(statement['preset'], 'task_consent');
    expect(statement['broadcast'], isTrue);
    expect(statement['anchor'], {'kind': 'task', 'id': _conversation});
    final attachment = _rows(statement['attachments']).single;
    expect(attachment['kind'], 'conventional_task_consent');
    expect(attachment['taskId'], _task);
    expect(attachment['recipientActor'], 'external-actor');
    expect(attachment['writablePaths'], ['lib/main.dart', 'lib/title.dart']);
    final expiry = DateTime.parse(attachment['expiresAt']! as String);
    expect(expiry.isUtc, isTrue);
    expect(
      expiry.difference(DateTime.now()).inMinutes,
      inInclusiveRange(14, 15),
    );
    expect(
      _rows(WorldConversationView.active!.projection['events']).single['beat'],
      'owner-1',
    );
    await unmount(tester);
  });

  testWidgets(
    'tool revoke uses the visible view and returns the owner receipt',
    (tester) async {
      await mount(tester);
      final tool = worldInspectorMcpEntries().singleWhere(
        (entry) => entry.name == 'world_conversation',
      );
      final result = await tool.invokeDirect({
        'op': 'revoke',
        'taskId': _task,
        'recipientActor': 'external-actor',
        'paths': ['lib/main.dart'],
        'durationSeconds': 300,
      });
      expect(result.data['ok'], isTrue);
      expect(
        _map(_map(result.data['receipt'])['interaction'])['beat'],
        'owner-1',
      );
      expect(owner.messages.single['preset'], 'task_consent_revoke');
      expect(
        _rows(owner.messages.single['attachments']).single['taskId'],
        _task,
      );
      await unmount(tester);
    },
  );

  testWidgets(
    'owner refusal is not success; explicit retry preserves request and expiry',
    (tester) async {
      await mount(tester);
      owner.refuseNext = true;
      final tool = worldInspectorMcpEntries().singleWhere(
        (entry) => entry.name == 'world_conversation',
      );
      const request = <String, Object?>{
        'op': 'authorize',
        'taskId': _task,
        'recipientActor': 'external-actor',
        'paths': ['lib/main.dart'],
        'durationSeconds': 300,
      };
      final refused = await tool.invokeDirect(request);
      expect(refused.data['ok'], isFalse);
      expect(
        refused.data['error'],
        contains('task_consent_issuer_not_allowed'),
      );
      expect(WorldConversationView.active!.projection['events'], isEmpty);
      await tester.pump(const Duration(seconds: 3));
      expect(
        owner.messages,
        hasLength(1),
        reason: 'polling must never replay consent',
      );
      final retry = await tool.invokeDirect(request);
      expect(retry.data['ok'], isTrue);
      expect(owner.messages, hasLength(2));
      expect(owner.messages.first, owner.messages.last);
      await unmount(tester);
    },
  );

  testWidgets(
    'unknown tasks, traversal, wildcards and invalid duration send nothing',
    (tester) async {
      await mount(tester);
      final view = WorldConversationView.active!;
      for (final (task, paths, duration) in [
        ('invisible-task', ['lib/main.dart'], 300),
        (_task, ['../main.dart'], 300),
        (_task, ['lib/*.dart'], 300),
        (_task, ['lib/main.dart'], 3601),
      ]) {
        await expectLater(
          view.taskConsent(
            taskId: task,
            recipientActor: 'external-actor',
            paths: paths,
            durationSeconds: duration,
          ),
          throwsStateError,
        );
      }
      expect(owner.messages, isEmpty);
      await unmount(tester);
    },
  );

  testWidgets('dismissing task permission sends no statement', (tester) async {
    await mount(tester);
    await tester.tap(find.byKey(const Key('world_conversation.consent')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('world_conversation.consent.cancel')),
    );
    await tester.pumpAndSettle();
    expect(owner.messages, isEmpty);
    await unmount(tester);
  });
}
