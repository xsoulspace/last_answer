import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// 1g/1d — the room UX laws, pinned:
/// - the replyTo quote and the addressedTo chips render from DURABLE
///   beat facts (never invented client-side);
/// - the chips mark a PROPER SUBSET only (addressing everyone is the
///   default, not a fact);
/// - the "N new" divider captures the human's receipt AT ROOM ENTRY
///   (reading IS the receipt, so the projection is already ahead by
///   the time the tail lands);
/// - Reply rides `say(replyTo:)` end-to-end;
/// - a thread no rail object names maps to its own `room:<threadId>`
///   surface id, and actor↔actor rooms are watchable (listed).
void main() {
  group('room: surface vocabulary (1d)', () {
    test(
      'an unnamed thread maps to room:<threadId>, named ones keep slots',
      () {
        const actor = ActorProfile(actorId: 'a1', displayName: 'Ada');
        expect(
          conversationSurfaceId(
            activeThreadId: 't9',
            channels: const [],
            actors: const [],
            dmThreadOf: (_) => null,
          ),
          'room:t9',
        );
        expect(
          conversationSurfaceId(
            activeThreadId: 't9',
            channels: const [],
            actors: const [actor],
            dmThreadOf: (final id) => id == 'a1' ? 't9' : null,
          ),
          'dm:a1',
        );
        expect(
          conversationSurfaceId(
            activeThreadId: null,
            channels: const [],
            actors: const [],
            dmThreadOf: (_) => null,
          ),
          isNull,
        );
        expect(isConversationSurfaceId('room:t9'), isTrue);
        expect(kindOfSurfaceId('room:t9'), kConversationsSurfaceId);
        expect(
          conversationSurfaceTitle(
            'room:t9',
            channels: const [],
            actors: const [],
            topicOf: (final id) => id == 't9' ? 'Ada ⇄ Grace' : null,
          ),
          'Ada ⇄ Grace',
        );
      },
    );
  });

  testWidgets(
    'replyTo quotes and addressedTo chips render from the durable beats',
    (final tester) async {
      late final RealmChatService service;
      late final RealmWorld world;
      late final ActorProfile ada;
      late final ActorProfile grace;
      late final String threadId;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_roomux_');
        addTearDown(() => temp.delete(recursive: true));
        world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        ada = (await service.createActor(
          displayName: 'Ada',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        grace = (await service.createActor(
          displayName: 'Grace',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        await service.startThread(
          topic: 'the room',
          participants: <String>[ada.actorId, grace.actorId],
        );
        threadId = service.activeThreadId!;
        // The human's word addresses EVERYONE (the default): beat 1.
        await service.say('hello room');
        // Ada addresses a PROPER SUBSET (a mention): beat 2.
        await world
            .sessionFor(ada.actorId)
            .say(
              threadId,
              'targeted word',
              addressedTo: <String>[grace.actorId],
            );
        // Grace answers beat 1 (the quote): beat 3.
        await world
            .sessionFor(grace.actorId)
            .say(threadId, 'answering', replyTo: 1);
        await service.refreshThreads();
        // Force the tail reload (selectThread no-ops on the ACTIVE
        // thread; the sessionFor beats bypassed the service's own
        // refresh).
        service.clearActiveThread();
        service.selectThread(threadId);
        // Let the tail read land.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<RealmChatService>.value(
          value: service,
          child: MaterialApp(
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(body: WorldChatSurface(service: service)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The mention chip: a proper subset only.
      expect(find.text('@Grace'), findsOneWidget);
      // The human's beat addressed everyone → NO chip row for it.
      expect(find.text('@Ada'), findsNothing);
      // The replyTo quote renders under Grace's beat.
      final quote = find.byKey(ValueKey('worldchat.quote.$threadId#1'));
      expect(quote, findsOneWidget);
      expect(
        find.descendant(of: quote, matching: find.textContaining('hello room')),
        findsOneWidget,
      );
    },
  );

  testWidgets('the "N new" divider captures the receipt at entry', (
    final tester,
  ) async {
    late final RealmChatService service;
    late final RealmWorld world;
    late final LaWorld laWorld;
    late final ActorProfile ada;
    late final String threadId;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_divider_');
      addTearDown(() => temp.delete(recursive: true));
      world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      ada = (await service.createActor(
        displayName: 'Ada',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      await service.openDm(ada.actorId);
      threadId = service.activeThreadId!;
      await service.say('first word');
      await world.sessionFor(ada.actorId).say(threadId, 'second word');
      await world.sessionFor(ada.actorId).say(threadId, 'third word');
      await service.refreshThreads();
      // The projection the shell would fold: the human read up to
      // beat 1; two beats arrived since.
      laWorld = LaWorld(humanActorId: () => service.humanActorId!);
      addTearDown(laWorld.dispose);
      laWorld.putRoom(
        RoomRow(
          threadId: threadId,
          topic: 'Ada',
          participants: <String>[service.humanActorId!, ada.actorId],
          lastBeat: 3,
        ),
      );
      laWorld.putRoomReceipt(threadId, 1);
      service.clearActiveThread();
      service.selectThread(threadId);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: Provider<LaWorld?>.value(
          value: laWorld,
          child: MaterialApp(
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(body: WorldChatSurface(service: service)),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final divider = find.byKey(const ValueKey('worldchat.unreadDivider'));
    expect(divider, findsOneWidget);
    expect(
      find.descendant(of: divider, matching: find.text('2 new')),
      findsOneWidget,
    );
  });

  testWidgets('Reply rides say(replyTo:) end-to-end', (final tester) async {
    late final RealmChatService service;
    late final RealmWorld world;
    late final ActorProfile ada;
    late final String threadId;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_reply_');
      addTearDown(() => temp.delete(recursive: true));
      world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      ada = (await service.createActor(
        displayName: 'Ada',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      await service.openDm(ada.actorId);
      threadId = service.activeThreadId!;
      await world
          .sessionFor(ada.actorId)
          .say(
            threadId,
            'a question worth '
            'answering precisely',
          );
      await service.refreshThreads();
      service.clearActiveThread();
      service.selectThread(threadId);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<RealmChatService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(body: WorldChatSurface(service: service)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Right-click the beat → Reply → the composer anchors.
    final beatRow = find.byKey(ValueKey('worldchat.beat.$threadId#1'));
    expect(beatRow, findsOneWidget);
    await tester.tap(
      beatRow,
      buttons: kSecondaryMouseButton,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('worldchat.replying')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('worldchat.composer')),
      'precisely this',
    );
    await tester.tap(find.byKey(const ValueKey('worldchat.send')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    // The reply strip clears and the new human beat carries the quote.
    expect(find.byKey(const ValueKey('worldchat.replying')), findsNothing);
    expect(find.byKey(ValueKey('worldchat.quote.$threadId#1')), findsWidgets);
    // And the journal itself carries replyTo (the durable fact).
    await tester.runAsync(() async {
      final read = await world.conversation().read(
        actor: world.authorityFor(service.humanActorId!),
        threadId: threadId,
      );
      final beats = (read['beats']! as List).cast<Map>();
      final last = beats.last;
      expect(last['text'], 'precisely this');
      expect(last['replyTo'], 1);
    });
  });

  testWidgets('roomThreads lists the watchable rooms, never DMs', (
    final tester,
  ) async {
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_rooms_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      final service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      final ada = (await service.createActor(
        displayName: 'Ada',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      final grace = (await service.createActor(
        displayName: 'Grace',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      // A DM (never a "room" row — it has its own rail slot).
      await service.openDm(ada.actorId);
      final dmThread = service.activeThreadId!;
      // An actor↔actor room the human merely watches (1d).
      await world.registerActor(ada.actorId);
      final opened = await world.conversation().open(
        actor: world.authorityFor(ada.actorId),
        topic: 'Ada ⇄ Grace',
        participants: <String>[grace.actorId],
        realmSealed: true,
      );
      final actorRoom = opened['threadId']! as String;
      await world.sessionFor(ada.actorId).say(actorRoom, 'between us');
      await service.refreshThreads();

      final rooms = service.roomThreads;
      final roomIds = rooms.map((final room) => room['threadId']).toList();
      expect(roomIds, contains(actorRoom));
      expect(roomIds, isNot(contains(dmThread)));
      expect(service.topicOf(actorRoom), 'Ada ⇄ Grace');
      expect(service.knowsThread(actorRoom), isTrue);
      expect(service.knowsThread('ghost'), isFalse);
    });
  });
}
