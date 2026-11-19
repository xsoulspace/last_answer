// DESIGN.md v2, cut to the bone (owner law 2026-11-10; ADR 0032's
// amendment) — the action bar is FOUR buttons: rail.search (the
// palette trigger), rail.actors (the rooms-column dock toggle,
// selected while docked, wearing the total unread badge),
// rail.automations (the device's declared automations) and
// rail.settings. The nine kind buttons retired with their cycling
// law. The badge keeps the 1g LaWorld contract (ported from the
// retired kind-button test): it totals every room the member has not
// read; the receipt clears it; no LaWorld = honest absence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_journal/actor_roster.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ecs_world/world.dart';
import 'package:lastanswer/ecs_world/world_components.dart';
import 'package:lastanswer/ui_shell/action_bar.dart';
import 'package:lastanswer/ui_shell/shell_layout.dart';

Future<void> _pumpBar(
  final WidgetTester tester, {
  final ShellLayout? layout,
  final LaWorld? laWorld,
  final bool actorsDocked = true,
  final List<bool> toggled = const [],
}) async {
  await tester.pumpWidget(
    Provider<LaWorld?>.value(
      value: laWorld,
      child: MaterialApp(
        // The kit overlay host (same shape as last_answer_app.dart):
        // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
        builder: (final context, final child) =>
            Portal(child: child ?? const SizedBox.shrink()),localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ActionBar(
            layout: layout ?? ShellLayout.defaultLayout(),
            actorsDocked: actorsDocked,
            onToggleActors: () => toggled.add(actorsDocked),
            onOpenAutomations: () {},
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
  testWidgets('the cut bar: FOUR buttons on the rail.* key contract, '
      'no kind buttons; the actors button reports its toggle', (
    final tester,
  ) async {
    final toggled = <bool>[];
    await _pumpBar(tester, toggled: toggled);
    expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.actors')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.automations')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.settings')), findsOneWidget);
    // The kind buttons retired — the vocabulary must not linger.
    expect(
      find.byWidgetPredicate(
        (final widget) =>
            widget.key is ValueKey &&
            (widget.key! as ValueKey).value.toString().startsWith('rail.view.'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('rail.actors')));
    await tester.pump();
    expect(toggled, <bool>[true]);
  });

  testWidgets('the actors button is selected WHILE docked and unselected '
      'undocked (the projection fact)', (final tester) async {
    Finder actorsButton({required final bool selected}) =>
        find.byWidgetPredicate(
          (final widget) =>
              widget is Semantics &&
              widget.properties.label == 'rail.actors' &&
              widget.properties.selected == selected,
        );
    await _pumpBar(tester);
    expect(actorsButton(selected: true), findsOneWidget);
    expect(actorsButton(selected: false), findsNothing);
    await _pumpBar(tester, actorsDocked: false);
    expect(actorsButton(selected: false), findsOneWidget);
    expect(actorsButton(selected: true), findsNothing);
  });

  testWidgets('no LaWorld = honest absence: no badge renders', (
    final tester,
  ) async {
    await _pumpBar(tester);
    expect(find.byKey(const ValueKey('rail.unread.actors')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the unread badge (1g, bar level): LaWorld feeds it '
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
      laWorld
        ..putRoom(
          RoomRow(
            threadId: threadId,
            topic: 'Badge Bot',
            lastBeat: 3,
            participants: [service.humanActorId!, actorId],
          ),
        )
        ..commitBatch();
    });

    await _pumpBar(tester, laWorld: laWorld);

    final badge = find.byKey(const ValueKey('rail.unread.actors'));
    expect(badge, findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // The receipt clears it reactively (one batch, one rebuild).
    laWorld
      ..putRoomReceipt(threadId, 3)
      ..commitBatch();
    await tester.pump();
    expect(find.text('3'), findsNothing);

    // A new beat re-badges with the fresh delta.
    laWorld
      ..putRoom(
        RoomRow(
          threadId: threadId,
          topic: 'Badge Bot',
          lastBeat: 4,
          participants: [service.humanActorId!, actorId],
        ),
      )
      ..commitBatch();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
