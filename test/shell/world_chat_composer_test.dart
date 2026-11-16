/// Wave E — the composer laws, pinned over the REAL [RealmChatService]
/// on a hermetic temp-dir [RealmWorld] (the rail_sem_probe_test /
/// world_chat_work_threads_test house pattern):
/// (a) the attach button REPLACES the bare scope toggle and opens ONE
///     search menu over the merged mentionables (actors + channels +
///     rooms); the search field filters the ONE list; picking a row
///     inserts the mention token at the composer caret; the Plugins and
///     MCP rows are honest-disabled;
/// (b) the menu's Work order row opens the EXISTING ADR 0129 scope
///     picker unchanged (options OR its named empty state — whichever
///     the hermetic world honestly has);
/// (c) typing `@` opens the filtered completion overlay above the
///     composer; picking replaces the partial token; the send still
///     rides the plain `say` (the addressedTo-override gap is
///     documented on the surface — the no-mention default is exactly
///     today's behavior).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One hermetic channel room: a temp-dir world, the real service over
/// it, one rostered actor, a `#guild` channel with that actor as a
/// member (createChannel selects it) and the human's first beat.
final class _Room {
  _Room({
    required this.world,
    required this.service,
    required this.channelThreadId,
    required this.humanId,
    required this.worker,
  });

  final RealmWorld world;
  final RealmChatService service;
  final String channelThreadId;
  final String humanId;
  final ActorProfile worker;
}

Future<_Room> _openRoom(
  final WidgetTester tester,
  final String label,
) async {
  SharedPreferences.setMockInitialValues({});
  final pin = Directory.systemTemp.createTempSync('wc_composer_$label');
  RealmWorld.debugDeviceHome = pin.path;
  addTearDown(() {
    RealmWorld.debugDeviceHome = null;
    pin.deleteSync(recursive: true);
  });
  late final _Room room;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('wc_composer_ws_');
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
    await service.say('kickoff');
    room = _Room(
      world: world,
      service: service,
      channelThreadId: channel!.threadId,
      humanId: service.humanActorId!,
      worker: worker,
    );
  });
  return room;
}

/// Pumps the chat surface the house way: the service via its own seam
/// AND the provider, pinned to EN.
Future<void> _pumpSurface(
  final WidgetTester tester,
  final RealmChatService service, {
  final void Function(String actorId)? onTapActor,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<RealmChatService>.value(
      value: service,
      child: MaterialApp(
        // The kit overlay host (same shape as last_answer_app.dart):
        // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
        builder: (final context, final child) =>
            Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
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

void main() {
  testWidgets(
    'a — the attach button replaces the scope toggle; its menu holds ONE '
    'merged filtered list and inserts the mention token at the caret',
    (final tester) async {
      final room = await _openRoom(tester, 'attach');
      await _pumpSurface(tester, room.service);

      // The bare scope toggle is gone; the attach button took its place.
      expect(
        find.byKey(const ValueKey('worldchat.scope.toggle')),
        findsNothing,
      );
      final attach = find.byKey(const ValueKey('worldchat.attach'));
      expect(attach, findsOneWidget);

      await tester.tap(attach);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('worldchat.attach.dialog')),
        findsOneWidget,
      );

      // ONE merged list: the actor AND the channel share it, and the
      // action rows ride below (work order enabled; plugins + MCP
      // honest-disabled via their Semantics).
      Semantics semanticsOf(final Finder row) => tester.widget<Semantics>(
        find.descendant(of: row, matching: find.byType(Semantics)).first,
      );
      final workerRow = find.byKey(
        ValueKey('worldchat.attach.actor.${room.worker.actorId}'),
      );
      final channelRow = find.byKey(
        ValueKey('worldchat.attach.channel.${room.channelThreadId}'),
      );
      expect(workerRow, findsOneWidget);
      expect(channelRow, findsOneWidget);
      final workOrder = find.byKey(
        const ValueKey('worldchat.attach.workOrder'),
      );
      expect(workOrder, findsOneWidget);
      expect(semanticsOf(workOrder).properties.enabled, isNot(isFalse));
      for (final key in const [
        'worldchat.attach.plugins',
        'worldchat.attach.mcp',
      ]) {
        final row = find.byKey(ValueKey(key));
        expect(row, findsOneWidget);
        // The named absence: a disabled row (never a fake affordance).
        expect(semanticsOf(row).properties.enabled, isFalse);
      }

      // The search field filters the ONE list.
      await tester.enterText(
        find.byKey(const ValueKey('worldchat.attach.search')),
        'wor',
      );
      await tester.pump();
      expect(workerRow, findsOneWidget);
      expect(channelRow, findsNothing);

      // Picking inserts the mention token at the (empty) caret.
      await tester.tap(workerRow);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('worldchat.attach.dialog')),
        findsNothing,
      );
      expect(find.text('@Worker A '), findsOneWidget);

      // The focused composer's caret law: unfocus + settle at the end.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'b — the Work order row opens the EXISTING scope picker (ADR 0129 '
    'lane unchanged): options or its named empty state',
    (final tester) async {
      final room = await _openRoom(tester, 'workorder');
      await _pumpSurface(tester, room.service);

      await tester.tap(find.byKey(const ValueKey('worldchat.attach')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(
        find.byKey(const ValueKey('worldchat.attach.workOrder')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The attach dialog handed off to the picker…
      expect(
        find.byKey(const ValueKey('worldchat.attach.dialog')),
        findsNothing,
      );
      // …whose option list is REAL IO: it settles in a runAsync window,
      // then renders EITHER the options OR the honest empty state
      // (a hermetic world without grants/folders has nothing to pick).
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      final pickerList = find.byKey(const ValueKey('worldchat.scope.picker'));
      final pickerEmpty = find.text(
        'No project scopes yet — add a workspace folder or grant '
        'access first.',
      );
      expect(
        pickerList.evaluate().isNotEmpty || pickerEmpty.evaluate().isNotEmpty,
        isTrue,
        reason: 'the scope picker (or its named empty state) must open',
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'c — typing @ opens the filtered overlay above the composer; picking '
    'replaces the partial token and the send rides the plain say',
    (final tester) async {
      final room = await _openRoom(tester, 'mention');
      await _pumpSurface(tester, room.service);

      final composer = find.byKey(const ValueKey('worldchat.composer'));
      await tester.enterText(composer, 'hey @Wo');
      await tester.pump();

      // The overlay anchors above the composer, filtered by the partial
      // token: the worker matches, the channel does not.
      expect(
        find.byKey(const ValueKey('worldchat.mentionOverlay')),
        findsOneWidget,
      );
      final workerRow = find.byKey(
        ValueKey('worldchat.mention.actor.${room.worker.actorId}'),
      );
      expect(workerRow, findsOneWidget);
      expect(
        find.byKey(
          ValueKey('worldchat.mention.channel.${room.channelThreadId}'),
        ),
        findsNothing,
      );

      // Picking replaces `@Wo` with the full token (trailing space).
      await tester.tap(workerRow);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('worldchat.mentionOverlay')),
        findsNothing,
      );
      expect(find.text('hey @Worker A '), findsOneWidget);

      // The send is the plain `say` — the mention rides the beat text
      // verbatim (the addressedTo override is the reported gap).
      await tester.tap(find.byKey(const ValueKey('worldchat.send')));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byKey(
          ValueKey('worldchat.beat.${room.channelThreadId}#2'),
        ),
        findsOneWidget,
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
