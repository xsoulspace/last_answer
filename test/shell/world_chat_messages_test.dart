/// Wave E — the message + channel-meta laws, pinned over the REAL
/// [RealmChatService] on a hermetic temp-dir [RealmWorld] (the house
/// pattern of world_chat_work_threads_test.dart, driven through the
/// widget):
/// (a) the meta row renders for a CHANNEL room and hides for a DM;
/// (b) the members popover hands the tapped actor to `onTapActor`;
/// (c) the pointer hover reveals the beat's action cluster (reply /
///     edit / new thread / menu): edit renders ONLY on own beats and is
///     DISABLED with the append-only-journal gap tooltip; reply anchors
///     the composer;
/// (d) the beat menu carries the extended items — edit and delete are
///     honest-disabled rows with their gap tooltips;
/// (e) "new thread" from a WORK thread's beat creates the child through
///     `startThread` (which selects it — the existing open path) and
///     links it under the ONE-LEVEL law: the link's parent is the ROOT
///     channel, never the work thread.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One hermetic channel room with BOTH voices in it: the human's
/// `kickoff` (beat #1) and the worker's own `noted` (beat #2, said
/// through the worker's world session), plus a two-member DM thread for
/// the channel-vs-DM meta-row law. Ends with the channel selected.
final class _Room {
  _Room({
    required this.temp,
    required this.world,
    required this.service,
    required this.channelThreadId,
    required this.dmThreadId,
    required this.humanId,
    required this.worker,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final String channelThreadId;
  final String dmThreadId;
  final String humanId;
  final ActorProfile worker;
}

Future<_Room> _openRoom(
  final WidgetTester tester,
  final String label,
) async {
  SharedPreferences.setMockInitialValues({});
  final pin = Directory.systemTemp.createTempSync('wc_messages_$label');
  RealmWorld.debugDeviceHome = pin.path;
  addTearDown(() {
    RealmWorld.debugDeviceHome = null;
    pin.deleteSync(recursive: true);
  });
  late final _Room room;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('wc_messages_ws_');
    addTearDown(() => temp.delete(recursive: true));
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    final service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(service.dispose);
    service.firstRunSeedEnabled = false;
    await service.ensureReady();
    expect(service.isReady, isTrue, reason: service.error);
    final worker = (await service.createActor(
      displayName: 'Worker A',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    final channel = await service.createChannel(
      'guild',
      memberIds: <String>[worker.actorId],
    );
    expect(channel, isNotNull, reason: service.error);
    final chan = channel!;
    await service.say('kickoff');
    // The DM twin for the meta-row law: a SECOND actor outside the
    // channel — openDm on a channel member would resolve to the channel
    // thread itself (a two-participant thread IS its DM), which is a
    // channel room, not a DM (the dedupe law, paid for 2026-11-10).
    final dmPeer = (await service.createActor(
      displayName: 'Worker B',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    await service.openDm(dmPeer.actorId);
    final dmThreadId = service.activeThreadId!;
    // Back to the channel; the worker's own beat makes it a two-voice
    // room (the journal watch's debounce lands it in the projection).
    service.selectThread(chan.threadId);
    await world.sessionFor(worker.actorId).say(chan.threadId, 'noted');
    // The worker's beat lands through the journal watch's debounce:
    // poll the JOURNAL (beatsFor is a pure read), then wait the 300ms
    // debounce out so the service's cached projection — the one the
    // pane renders — refreshes before the fake clock takes over.
    for (var waited = 0; waited < 20; waited++) {
      if ((await service.beatsFor(chan.threadId)).length >= 2) break;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    await Future<void>.delayed(const Duration(milliseconds: 450));
    // The watch lane keys on journal flushes, which a hermetic append
    // may not reach inside the test window; re-selecting the thread
    // refreshes the cached beats through the public lane instead
    // (selectThread no-ops on the SAME id, so toggle via the DM).
    service.selectThread(dmThreadId);
    service.selectThread(chan.threadId);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    room = _Room(
      temp: temp,
      world: world,
      service: service,
      channelThreadId: chan.threadId,
      dmThreadId: dmThreadId,
      humanId: service.humanActorId!,
      worker: worker,
    );
  });
  return room;
}

/// Pumps the chat surface the house way: the service via its own seam
/// AND the provider, pinned to EN, with the Wave E `onTapActor` seam.
Future<void> _pumpSurface(
  final WidgetTester tester,
  final RealmChatService service, {
  final void Function(String actorId)? onTapActor,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<RealmChatService>.value(
      value: service,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: WorldChatSurface(service: service, onTapActor: onTapActor),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// A real mouse pointer the hover laws need (MouseRegion events ride a
/// mouse device — a touch tap never hovers).
Future<TestGesture> _mouse(
  final WidgetTester tester,
) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets(
    'a — the meta row renders for a channel room and hides for a DM',
    (final tester) async {
      final room = await _openRoom(tester, 'meta');
      await _pumpSurface(tester, room.service);

      // The channel is active: ONE row of the three icon buttons.
      for (final key in const [
        'worldchat.meta.perms',
        'worldchat.meta.members',
        'worldchat.meta.info',
      ]) {
        expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
      }

      // The DM hides it (a DM's identity lives in the header; there are
      // no channel-registry facts to show).
      await tester.runAsync(() async {
        room.service.selectThread(room.dmThreadId);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      for (final key in const [
        'worldchat.meta.perms',
        'worldchat.meta.members',
        'worldchat.meta.info',
      ]) {
        expect(find.byKey(ValueKey(key)), findsNothing, reason: key);
      }

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'b — the members popover lists the channel members and one tap '
    'fires onTapActor with the actor id',
    (final tester) async {
      final room = await _openRoom(tester, 'members');
      final captured = <String>[];
      await _pumpSurface(tester, room.service, onTapActor: captured.add);

      await tester.tap(find.byKey(const ValueKey('worldchat.meta.members')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('worldchat.meta.members.popover')),
        findsOneWidget,
      );
      final workerRow = find.byKey(
        ValueKey('worldchat.meta.member.${room.worker.actorId}'),
      );
      expect(workerRow, findsOneWidget);

      await tester.tap(workerRow);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(captured, <String>[room.worker.actorId]);
      expect(
        find.byKey(const ValueKey('worldchat.meta.members.popover')),
        findsNothing,
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'c — hover reveals the action cluster: edit is own-only and '
    'disabled with the gap tooltip; reply anchors the composer',
    (final tester) async {
      final room = await _openRoom(tester, 'hover');
      await _pumpSurface(tester, room.service);
      final l10n = S.of(tester.element(find.byType(WorldChatSurface)));

      final beat1 = find.byKey(
        ValueKey('worldchat.beat.${room.channelThreadId}#1'),
      );
      final beat2 = find.byKey(
        ValueKey('worldchat.beat.${room.channelThreadId}#2'),
      );
      // The pane's beat load is async and the composer's cursor blink
      // forbids pumpAndSettle: bounded pumps until the worker's row
      // lands (the fixture polled the service, the pane lags a frame).
      for (var i = 0; i < 10 && beat2.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(beat1, findsOneWidget);
      expect(beat2, findsOneWidget);
      final suffix1 = '${room.channelThreadId}#1';
      final suffix2 = '${room.channelThreadId}#2';

      // No pointer, no cluster (the row is calm chrome at rest).
      expect(
        find.byKey(ValueKey('worldchat.beat.reply.$suffix1')),
        findsNothing,
      );

      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(beat1));
      await tester.pump();

      // The cluster: reply, edit (OWN beat — the human wrote kickoff),
      // new thread, menu.
      expect(
        find.byKey(ValueKey('worldchat.beat.reply.$suffix1')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('worldchat.beat.thread.$suffix1')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('worldchat.beat.menu.$suffix1')),
        findsOneWidget,
      );
      final edit = find.byKey(ValueKey('worldchat.beat.edit.$suffix1'));
      expect(edit, findsOneWidget);
      final editButton = tester.widget<IconButton>(edit);
      expect(editButton.onPressed, isNull);
      expect(editButton.tooltip, l10n.worldChatEditGap);

      // Reply anchors the composer (the context menu's own behavior).
      await tester.tap(find.byKey(ValueKey('worldchat.beat.reply.$suffix1')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('worldchat.replying')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('worldchat.replying.close')),
      );
      await tester.pump();

      // The worker's beat: NO edit row (edit is own-only, honestly
      // absent rather than disabled).
      await mouse.moveTo(tester.getCenter(beat2));
      await tester.pump();
      expect(
        find.byKey(ValueKey('worldchat.beat.reply.$suffix2')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('worldchat.beat.edit.$suffix2')),
        findsNothing,
      );

      // Leaving the row takes the cluster with it.
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(
        find.byKey(ValueKey('worldchat.beat.reply.$suffix2')),
        findsNothing,
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'd — the beat menu extends the context items: edit and delete are '
    'honest-disabled rows with their gap tooltips',
    (final tester) async {
      final room = await _openRoom(tester, 'menu');
      await _pumpSurface(tester, room.service);
      final l10n = S.of(tester.element(find.byType(WorldChatSurface)));

      final beat1 = find.byKey(
        ValueKey('worldchat.beat.${room.channelThreadId}#1'),
      );
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(beat1));
      await tester.pump();
      await tester.tap(
        find.byKey(
          ValueKey('worldchat.beat.menu.${room.channelThreadId}#1'),
        ),
      );
      // Popup-menu law: settle the entrance before touching items.
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('worldchat.ctx.reply')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('worldchat.ctx.details')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('worldchat.ctx.thread')),
        findsOneWidget,
      );

      String tooltipOf(final String key) => tester
          .widget<Tooltip>(
            find.descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(Tooltip),
            ).first,
          )
          .message!;

      // Own beat → the edit row exists, disabled, naming the gap: the
      // journal is append-only and the verb is harness-owned.
      final editItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const ValueKey('worldchat.ctx.edit')),
      );
      expect(editItem.enabled, isFalse);
      expect(tooltipOf('worldchat.ctx.edit'), l10n.worldChatEditGap);

      // Delete: disabled for every beat, gap tooltip naming the law.
      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const ValueKey('worldchat.ctx.delete')),
      );
      expect(deleteItem.enabled, isFalse);
      expect(tooltipOf('worldchat.ctx.delete'), l10n.worldChatDeleteGap);

      // Dismiss the menu (barrier tap) and settle the exit BEFORE any
      // runAsync window (the popup-exit ticker law).
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'e — new thread from a work thread creates the child via startThread '
    'and links it to the ROOT (the one-level law)',
    (final tester) async {
      final room = await _openRoom(tester, 'thread');
      late final String workId;
      late final String repoPath;
      await tester.runAsync(() async {
        final repo = Directory('${room.temp.path}/repo');
        await repo.create();
        repoPath = repo.path;
        final grant = await room.service.grantAccess(room.humanId, repoPath);
        expect(grant.granted, isTrue, reason: grant.message);
        final spawn = await room.service.spawnWorkThread(
          parentThreadId: room.channelThreadId,
          projectRoot: repoPath,
          memberIds: <String>[room.worker.actorId],
          orderText: 'audit imports',
        );
        expect(spawn.isSpawned, isTrue, reason: spawn.message);
        workId = spawn.workThread!.workThreadId;
        // Open the work thread (the card's own route) and let its order
        // beat land in the projection.
        room.service.selectThread(workId);
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await _pumpSurface(tester, room.service);
      final beat1 = find.byKey(ValueKey('worldchat.beat.$workId#1'));
      expect(beat1, findsOneWidget);

      // Hover → menu → New thread (the real IO rides a runAsync window
      // AFTER the popup-menu exit settles).
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(beat1));
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey('worldchat.beat.menu.$workId#1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('worldchat.ctx.thread')));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 900)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The child opened through the EXISTING route: startThread
      // selects what it creates.
      final childId = room.service.activeThreadId!;
      expect(childId, isNot(workId));
      expect(childId, isNot(room.channelThreadId));

      await tester.runAsync(() async {
        // HONEST GAP (documented on the surface): the service's
        // workThreads cache refreshes only inside its own spawn verb,
        // so a reuse-only spawn is the public trigger that makes the
        // fresh link visible through workThreadsOf (the durable
        // registry row landed with the click).
        final reuse = await room.service.spawnWorkThread(
          parentThreadId: room.channelThreadId,
          projectRoot: repoPath,
        );
        expect(reuse.reused, isTrue, reason: reuse.message);

        // The ONE-LEVEL law: the child links to the ROOT channel, not
        // to the work thread it was spawned from — no grandchildren.
        final child = room.service
            .workThreadsOf(room.channelThreadId)
            .firstWhere((final link) => link.workThreadId == childId);
        expect(child.parentThreadId, room.channelThreadId);
        // A conversational child carries no project seal: the link's
        // projectRoot is honestly empty, never an invented root.
        expect(child.projectRoot, '');
        expect(room.service.workThreadsOf(workId), isEmpty);

        // The durable row, read straight from the registry (the journal
        // store is the oracle, not the projection).
        final row = await WorkThreadRegistry(
          store: room.world.store,
        ).byWorkThreadId(childId);
        expect(row, isNotNull);
        expect(row!.parentThreadId, room.channelThreadId);
      });

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
