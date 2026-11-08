// DESIGN.md v2 — the action bar (the rail rethought): kind buttons on
// the rail.view.* vocabulary, the active pip as `selected` semantics,
// and the conversations kind's unread badge fed reactively by LaWorld
// (the 1g law, ported from the retired actor_rail_test to KIND level:
// the badge totals every room the member has not read; the receipt
// clears it; no LaWorld = honest absence).

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/shell/action_bar.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/surfaces.dart';

const _kinds = <ActionBarKind>[
  ActionBarKind(
    id: kConversationsSurfaceId,
    icon: Icons.forum_outlined,
    tooltip: 'Conversations',
  ),
  ActionBarKind(
    id: kBoardsSurfaceId,
    icon: Icons.view_kanban,
    tooltip: 'Boards',
  ),
];

Future<void> _pumpBar(
  final WidgetTester tester, {
  required ShellLayout layout,
  final LaWorld? laWorld,
  final List<String> tapped = const [],
}) async {
  await tester.pumpWidget(
    Provider<LaWorld?>.value(
      value: laWorld,
      child: MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ActionBar(
            layout: layout,
            kinds: _kinds,
            onKindTap: tapped.add,
            onOpenSettings: () {},
            onOpenPalette: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('kind buttons render on the rail.view.* key contract and '
      'report taps', (final tester) async {
    final tapped = <String>[];
    await _pumpBar(tester, layout: ShellLayout.defaultLayout(), tapped: tapped);
    expect(
      find.byKey(const ValueKey('rail.view.conversations')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('rail.view.boards')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.settings')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rail.view.boards')));
    await tester.pump();
    expect(tapped, <String>[kBoardsSurfaceId]);
  });

  testWidgets('no LaWorld = honest absence: no badge renders', (
    final tester,
  ) async {
    await _pumpBar(tester, layout: ShellLayout.defaultLayout());
    expect(
      find.byKey(const ValueKey('rail.unread.conversations')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the unread badge (1g, kind level): LaWorld feeds it '
      'reactively — the receipt clears it, a new beat re-badges', (
    final tester,
  ) async {
    late final RealmChatService service;
    late final LaWorld laWorld;
    late final String actorId;
    late final String threadId;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_bar_badge_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      final actor = (await service.createActor(
        displayName: 'Badge Bot',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      actorId = actor.actorId;
      await service.openDm(actorId);
      threadId = service.dmThreadOf(actorId)!;
      service.clearActiveThread();
      laWorld = LaWorld(humanActorId: () => service.humanActorId!);
      addTearDown(laWorld.dispose);
      laWorld.putRoom(
        RoomRow(
          threadId: threadId,
          topic: 'Badge Bot',
          lastBeat: 3,
          participants: [service.humanActorId!, actorId],
        ),
      );
      laWorld.commitBatch();
    });

    await _pumpBar(
      tester,
      layout: ShellLayout.defaultLayout(),
      laWorld: laWorld,
    );

    final badge = find.byKey(const ValueKey('rail.unread.conversations'));
    expect(badge, findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // The receipt clears it reactively (one batch, one rebuild).
    laWorld.putRoomReceipt(threadId, 3);
    laWorld.commitBatch();
    await tester.pump();
    expect(find.text('3'), findsNothing);

    // A new beat re-badges with the fresh delta.
    laWorld.putRoom(
      RoomRow(
        threadId: threadId,
        topic: 'Badge Bot',
        lastBeat: 4,
        participants: [service.humanActorId!, actorId],
      ),
    );
    laWorld.commitBatch();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
