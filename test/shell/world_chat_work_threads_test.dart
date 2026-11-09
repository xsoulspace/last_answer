/// ADR 0129 — the work-order UI laws, pinned over the REAL
/// [RealmChatService] on a hermetic temp-dir [RealmWorld] (the house
/// style of realm_work_thread_test.dart, driven through the widget):
/// (a) the scope chip arms/disarms, and a scoped send routes through
///     `spawnWorkThread` — the child is project-SEALED (the journal row
///     is the oracle), the order lands as ONE beat addressed to the
///     room's ACTOR members (humans excluded), the composer clears, the
///     chip stays armed and the fresh/reused status announces;
/// (b) the parent room's work card renders from the registry link with
///     the child's live last-beat preview, and its OPEN action selects
///     the child as the current room;
/// (c) `project_not_granted` renders the typed evidence verbatim plus
///     the one-tap grant; the REAL host `grantProjectAccess` (through
///     `service.grantAccess`) against the hermetic world home retries
///     the order exactly once and it lands;
/// (d) an unscoped send stays the plain `say` (regression).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// One hermetic room (realm_work_thread_test's `_Room` fixture,
/// mirrored): a temp-dir world, the real service over it, a
/// realm-sealed parent thread with one ROSTERED actor member, the
/// human's first beat (the stream — and its work strip — exists only
/// once the room has a beat), and a repo-shaped project root.
final class _Room {
  _Room({
    required this.temp,
    required this.world,
    required this.service,
    required this.parentThreadId,
    required this.humanId,
    required this.repoPath,
    required this.worker,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final String parentThreadId;
  final String humanId;
  final String repoPath;
  final ActorProfile worker;

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Room> _openRoom(
  final WidgetTester tester,
  final String label, {
  final bool seed = true,
}) async {
  late final _Room room;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('la_workui_$label');
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    final service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    await service.ensureReady();
    expect(service.isReady, isTrue, reason: service.error);
    final worker = (await service.createActor(
      displayName: 'Worker A',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    await service.startThread(
      topic: 'Parent room',
      participants: <String>[worker.actorId],
    );
    if (seed) await service.say('kickoff');
    final repo = Directory('${temp.path}/repo');
    await repo.create();
    room = _Room(
      temp: temp,
      world: world,
      service: service,
      parentThreadId: service.activeThreadId!,
      humanId: service.humanActorId!,
      repoPath: repo.path,
      worker: worker,
    );
  });
  addTearDown(room.dispose);
  return room;
}

/// Pumps the chat surface the house way: the service via its own seam
/// AND the provider (the strip's nullable reads), pinned to EN. A
/// [WorkspaceNotifier] is optional — production resolves it through the
/// app's DI; the hermetic shells that pass one exercise the picker's
/// folder lane.
Future<void> _pumpSurface(
  final WidgetTester tester,
  final RealmChatService service, {
  final WorkspaceNotifier? workspaces,
}) async {
  Widget app = MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: Scaffold(body: WorldChatSurface(service: service)),
  );
  if (workspaces != null) {
    app = ChangeNotifierProvider<WorkspaceNotifier>.value(
      value: workspaces,
      child: app,
    );
  }
  await tester.pumpWidget(
    ChangeNotifierProvider<RealmChatService>.value(value: service, child: app),
  );
  await tester.pump();
}

/// Arms [repoPath] through the real picker flow: toggle → dialog (the
/// option list is real IO — it settles in a runAsync window) → row tap
/// → the armed chip shows.
Future<void> _armScope(final WidgetTester tester, final String path) async {
  await tester.tap(find.byKey(const ValueKey('worldchat.scope.toggle')));
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 400)),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  final option = find.byKey(ValueKey('worldchat.scope.option.$path'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('worldchat.scope.armed')), findsOneWidget);
}

/// Lets the scoped send's real IO (spawn → registry → refreshes) land,
/// then flushes the continuation microtasks into the widget tree.
Future<void> _settleSpawn(final WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 900)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets(
    'a — the scope chip arms and disarms; a scoped send spawns the '
    'project-sealed work thread and forwards ONE addressed beat',
    (final tester) async {
      final room = await _openRoom(tester, 'arm');
      // The grant makes the repo both SELECTABLE (the picker lists the
      // human's durable grants) and sealable (ADR 0129's mint gate).
      await tester.runAsync(() async {
        final grant = await room.service.grantAccess(
          room.humanId,
          room.repoPath,
        );
        expect(grant.granted, isTrue, reason: grant.message);
      });
      await _pumpSurface(tester, room.service);

      // Arm: the picker lists the granted repo; the chip shows the scope.
      await _armScope(tester, room.repoPath);

      // Dismissible: the chip's × clears the arm (Send is a plain say
      // again — pinned by test d's shape).
      await tester.tap(find.byKey(const ValueKey('worldchat.scope.clear')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('worldchat.scope.armed')),
        findsNothing,
      );

      // Re-arm and send the work order.
      await _armScope(tester, room.repoPath);
      await tester.enterText(
        find.byKey(const ValueKey('worldchat.composer')),
        'please triage the failing test',
      );
      await tester.tap(find.byKey(const ValueKey('worldchat.send')));
      await _settleSpawn(tester);

      // The composer cleared, the chip STAYS armed (a workstream
      // continues — the owner's decision), and the honest FRESH-spawn
      // status announced.
      expect(find.text('please triage the failing test'), findsNothing);
      expect(
        find.byKey(const ValueKey('worldchat.scope.armed')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('worldchat.scope.status')),
        findsOneWidget,
      );
      expect(find.text('Work thread opened · repo'), findsOneWidget);

      // The parent room shows the work card (the link's projection).
      final link = room.service.workThreadsOf(room.parentThreadId).single;
      expect(
        find.byKey(ValueKey('worldchat.workthread.${link.workThreadId}')),
        findsOneWidget,
      );

      // The journal is the oracle: the child is SEALED to the repo, the
      // order landed as exactly ONE human beat addressed to the room's
      // ACTOR members (the human excluded), and the parent never saw
      // the order text (the link is its only knowledge).
      await tester.runAsync(() async {
        final row = await room.world.store.read(
          'threads',
          link.workThreadId,
        );
        expect(row?['projectId'], room.repoPath);
        final beats = await room.world.projection.beatsOfThread(
          link.workThreadId,
        );
        expect(beats, hasLength(1));
        expect(beats.single['text'], 'please triage the failing test');
        expect(beats.single['author'], room.humanId);
        expect(
          (beats.single['addressedTo']! as List).cast<String>(),
          <String>[room.worker.actorId],
        );
        final parentBeats = await room.world.projection.beatsOfThread(
          room.parentThreadId,
        );
        expect(
          parentBeats.where((final b) => '${b['text']}'.contains('triage')),
          isEmpty,
        );
      });

      // The transient status clears itself (and takes its timer with
      // it — no pending-timer teardown).
      await tester.pump(const Duration(seconds: 5));
      expect(
        find.byKey(const ValueKey('worldchat.scope.status')),
        findsNothing,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'b — the work card renders from the link with the child preview; '
    'OPEN selects the work thread as the current room',
    (final tester) async {
      final room = await _openRoom(tester, 'card');
      late final String workId;
      await tester.runAsync(() async {
        await room.service.grantAccess(room.humanId, room.repoPath);
        final spawn = await room.service.spawnWorkThread(
          parentThreadId: room.parentThreadId,
          projectRoot: room.repoPath,
          memberIds: <String>[room.worker.actorId],
          orderText: 'audit the imports',
        );
        expect(spawn.isSpawned, isTrue, reason: spawn.message);
        workId = spawn.workThread!.workThreadId;
        // The worker's answer: the child's last-beat preview fact
        // (author · text · instant) the parent's card projects. The
        // SEALED thread is only visible to granted actors (ADR 0121
        // visibility law — an ungranted say refuses thread_not_visible,
        // as the daemon-side sandbox will), so the worker holds the
        // project grant before it speaks.
        await room.service.grantAccess(room.worker.actorId, room.repoPath);
        await room.world
            .sessionFor(room.worker.actorId)
            .say(workId, 'on it');
        await room.service.refreshThreads();
      });
      await _pumpSurface(tester, room.service);

      // The card: the link's name (the project basename), the kind word
      // (never color alone), and the child's live preview.
      final card = find.byKey(ValueKey('worldchat.workthread.$workId'));
      expect(card, findsOneWidget);
      expect(find.text('repo'), findsOneWidget);
      expect(find.text('work thread'), findsOneWidget);
      final preview = find.byKey(
        ValueKey('worldchat.workthread.preview.$workId'),
      );
      expect(preview, findsOneWidget);
      expect(
        tester.widget<Text>(preview).data,
        startsWith('Worker A: on it'),
      );

      // OPEN selects the child through the existing room-selection
      // route (selectThread — the landing inbox's own).
      await tester.tap(
        find.byKey(ValueKey('worldchat.workthread.open.$workId')),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      expect(room.service.activeThreadId, workId);
      // The child room now renders its own beats (the order + answer).
      expect(
        find.byKey(ValueKey('worldchat.beat.$workId#1')),
        findsOneWidget,
      );
      expect(find.text('audit the imports'), findsOneWidget);
      expect(find.text('on it'), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'c — project_not_granted shows the typed evidence + the one-tap '
    'grant; the verified grant retries the order exactly once',
    (final tester) async {
      final room = await _openRoom(tester, 'refusal');
      // The repo is NOT granted; a registered workspace folder keeps it
      // SELECTABLE anyway (the picker is never the policy — the refusal
      // flow owns that honesty).
      late final WorkspaceNotifier workspaces;
      await tester.runAsync(() async {
        workspaces = WorkspaceNotifier(
          storeLoader: () async => room.world.store,
        );
        await workspaces.ensureLoaded();
        final created = await workspaces.create(
          name: 'repo ws',
          folderPaths: <String>[room.repoPath],
        );
        expect(created, isNotNull);
      });
      addTearDown(workspaces.dispose);
      await _pumpSurface(tester, room.service, workspaces: workspaces);

      await _armScope(tester, room.repoPath);
      await tester.enterText(
        find.byKey(const ValueKey('worldchat.composer')),
        'triage the leak',
      );
      await tester.tap(find.byKey(const ValueKey('worldchat.send')));
      await _settleSpawn(tester);

      // The typed refusal renders with its OWN evidence, verbatim: the
      // refusal name, the requested project, the current grants (the
      // app-support scope accrues; the repo does not) and the message.
      expect(
        find.byKey(const ValueKey('worldchat.spawnRefusal')),
        findsOneWidget,
      );
      expect(find.text('Project access needed'), findsOneWidget);
      expect(find.text('project_not_granted'), findsOneWidget);
      expect(find.text(room.repoPath), findsWidgets);
      final grants = tester.widget<Text>(
        find.byKey(const ValueKey('worldchat.spawnRefusal.grants')),
      );
      expect(grants.data, contains(room.world.root));
      expect(grants.data, isNot(contains(room.repoPath)));
      // The composer KEEPS the order text — nothing is lost.
      expect(find.text('triage the leak'), findsOneWidget);

      // One tap grants (the REAL host `grantProjectAccess` against the
      // hermetic world home, through the service's VERIFY re-read) and
      // retries the spawn ONCE with the refused order.
      await tester.tap(
        find.byKey(const ValueKey('worldchat.spawnRefusal.grant')),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1500)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The refusal card is gone; the work card and the honest
      // fresh-spawn status took its place.
      expect(
        find.byKey(const ValueKey('worldchat.spawnRefusal')),
        findsNothing,
      );
      final link = room.service.workThreadsOf(room.parentThreadId).single;
      expect(
        find.byKey(ValueKey('worldchat.workthread.${link.workThreadId}')),
        findsOneWidget,
      );
      expect(find.text('Work thread opened · repo'), findsOneWidget);

      // The order landed in the SEALED child, exactly once; the grant
      // is durable.
      await tester.runAsync(() async {
        final row = await room.world.store.read(
          'threads',
          link.workThreadId,
        );
        expect(row?['projectId'], room.repoPath);
        final beats = await room.world.projection.beatsOfThread(
          link.workThreadId,
        );
        expect(beats, hasLength(1));
        expect(beats.single['text'], 'triage the leak');
        expect(
          await room.service.listGrants(room.humanId),
          contains(room.repoPath),
        );
      });
      await tester.pump(const Duration(seconds: 5));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets('d — an unscoped send stays the plain say (regression)', (
    final tester,
  ) async {
    final room = await _openRoom(tester, 'plain');
    await _pumpSurface(tester, room.service);
    expect(find.byKey(const ValueKey('worldchat.scope.armed')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('worldchat.composer')),
      'just words',
    );
    await tester.tap(find.byKey(const ValueKey('worldchat.send')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // The beat landed in the PARENT room as a plain human beat…
    expect(find.text('just words'), findsOneWidget);
    expect(
      find.byKey(ValueKey('worldchat.beat.${room.parentThreadId}#2')),
      findsOneWidget,
    );
    // …and nothing spawned: no link, no registry row, no refusal card.
    expect(room.service.workThreads, isEmpty);
    expect(
      find.byKey(const ValueKey('worldchat.spawnRefusal')),
      findsNothing,
    );
    await tester.runAsync(() async {
      expect(await room.world.store.scan('work_threads'), isEmpty);
    });
  }, timeout: const Timeout(Duration(minutes: 2)));

  // (e) The day-one auto-spawn flow: a FRESH general room has no beats
  // yet when its first send becomes a work order — and the merged view
  // (the owner's auto-spawn law) is exactly the work card in that empty
  // room. Paid for by the 2026-11-09 live pilot: the strip used to hide
  // behind the first-word note, so the card was invisible until someone
  // spoke in the parent. The note now sits BEHIND the list, not instead
  // of it.
  testWidgets(
    'e — an empty parent room still shows the work card (the merged view)',
    (final tester) async {
      final room = await _openRoom(tester, 'empty', seed: false);
      late final String workId;
      await tester.runAsync(() async {
        await room.service.grantAccess(room.humanId, room.repoPath);
        final spawn = await room.service.spawnWorkThread(
          parentThreadId: room.parentThreadId,
          projectRoot: room.repoPath,
          memberIds: <String>[room.worker.actorId],
          orderText: 'audit the imports',
        );
        expect(spawn.isSpawned, isTrue, reason: spawn.message);
        workId = spawn.workThread!.workThreadId;
      });
      await _pumpSurface(tester, room.service);

      // The parent is still beat-less (the order lives in the child)…
      expect(find.text('kickoff'), findsNothing);
      // …yet the merged view shows both halves: the first-word note
      // behind, the work card in front.
      expect(find.textContaining('Say the first word'), findsOneWidget);
      expect(
        find.byKey(ValueKey('worldchat.workthread.$workId')),
        findsOneWidget,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
