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
/// composer; picking replaces the partial token; the send still
/// rides the plain `say` (the addressedTo-override gap is
/// documented on the surface — the no-mention default is exactly
/// today's behavior).
/// (d) the MESSENGER MEDIA law (2026-11-18): the old standalone image
/// button is gone; the attach menu carries an ENABLED image row, and an
/// OS drop on the composer field (the desktop_drop channel, simulated)
/// stages a pending-media chip showing the human's file name; the chip
/// removes; a re-drop plus a text send spends the strip as ONE media
/// beat with the attachment riding the record.
library;

import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
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

Future<_Room> _openRoom(final WidgetTester tester, final String label) async {
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
            Portal(child: child ?? const SizedBox.shrink()),
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

/// A VALID png (real magic — the media sniffer accepts it; the same
/// helper shape as the world_chat_media proof).
Uint8List pngBytes({final int width = 32, final int height = 24}) {
  final b = BytesBuilder();
  b.add([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  final ihdr = BytesBuilder()
    ..add([...utf8.encode('IHDR')])
    ..add([
      (width >> 24) & 0xff,
      (width >> 16) & 0xff,
      (width >> 8) & 0xff,
      width & 0xff,
      (height >> 24) & 0xff,
      (height >> 16) & 0xff,
      (height >> 8) & 0xff,
      height & 0xff,
      8,
      6,
      0,
      0,
      0,
    ]);
  final chunk = ihdr.toBytes();
  final length = chunk.length - 4;
  b.add([0, 0, (length >> 8) & 0xff, length & 0xff]);
  b.add(chunk);
  b.add([0, 0, 0, 0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]);
  return b.toBytes();
}

/// The desktop_drop channel's ENTER beat: macOS dispatches `entered`
/// with global logical coords inside the target; the framework routes
/// it to the enabled DropTarget, whose hover accent answers it.
Future<void> _fireDropEnter(
  final WidgetTester tester,
  final Finder target,
) async {
  final center = tester.getCenter(target);
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'desktop_drop',
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('entered', <double>[center.dx, center.dy]),
    ),
    (final data) {},
  );
  await tester.pump();
}

/// The desktop_drop channel's DROP beat: `performOperation` with the
/// dropped paths. The staging lane is real IO (read bytes → sniff →
/// world write) — settled in a runAsync window (the house image law).
Future<void> _fireDropPerform(
  final WidgetTester tester,
  final Finder target,
  final List<String> paths,
) async {
  // The staging lane is REAL IO (read bytes → sniff → world write);
  // both the dispatch and the settle ride ONE runAsync window, so the
  // whole chain runs outside the fake-async zone (the house law — the
  // media proof does exactly this for its share+say).
  await tester.runAsync(() async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'desktop_drop',
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('performOperation', paths),
      ),
      (final data) {},
    );
    // Bounded settle: the staging chain is real IO; give it a generous
    // real-time window before the test reads the tree.
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
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
      // The messenger media law: the image row is ENABLED (it stages),
      // and the old standalone image button is gone from the row — the
      // ⊕ menu is the composer's only pick affordance now.
      final imageRow = find.byKey(const ValueKey('worldchat.attach.image'));
      expect(imageRow, findsOneWidget);
      expect(semanticsOf(imageRow).properties.enabled, isNot(isFalse));
      expect(find.byKey(const ValueKey('worldchat.shareImage')), findsNothing);

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
        find.byKey(ValueKey('worldchat.beat.${room.channelThreadId}#2')),
        findsOneWidget,
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
  testWidgets('d — an OS drop on the composer STAGES a pending chip (messenger '
      'law): the chip shows the file name and removes; a re-drop plus a '
      'text send spends the strip as one media beat', (final tester) async {
    final room = await _openRoom(tester, 'drop');
    await _pumpSurface(tester, room.service);

    final composerField = find.byKey(const ValueKey('worldchat.composer'));
    expect(composerField, findsOneWidget);

    // A real png on disk — the drop carries a path, exactly like a
    // Finder drag does. SYNC creation: the fake-async zone never
    // resolves awaited real IO (the house image-test law).
    final dropDir = Directory.systemTemp.createTempSync('wc_drop_');
    addTearDown(() => dropDir.deleteSync(recursive: true));
    final png = File('${dropDir.path}/lighthouse-drop.png')
      ..writeAsBytesSync(pngBytes());

    // Enter proves the routing: the field lights ONE accent border.
    await _fireDropEnter(tester, composerField);
    await _fireDropPerform(tester, composerField, [png.path]);

    // The staged strip: the human's file name in a removable chip.
    expect(find.byKey(const ValueKey('worldchat.mediaStrip')), findsOneWidget);
    expect(find.byKey(const ValueKey('worldchat.mediaChip.0')), findsOneWidget);
    expect(find.text('lighthouse-drop.png'), findsOneWidget);

    // One tap removes the chip; the strip honest-absences away.
    await tester.tap(
      find.byKey(const ValueKey('worldchat.mediaChip.0.remove')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('worldchat.mediaStrip')), findsNothing);

    // Re-drop, then send WITH text: one beat, the attachment rides,
    // the strip is spent.
    await _fireDropEnter(tester, composerField);
    await _fireDropPerform(tester, composerField, [png.path]);
    expect(find.byKey(const ValueKey('worldchat.mediaChip.0')), findsOneWidget);
    await tester.enterText(composerField, 'here, the dropped lighthouse');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('worldchat.send')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(ValueKey('worldchat.beat.${room.channelThreadId}#2')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('worldchat.mediaStrip')), findsNothing);
    final beats = await tester.runAsync(
      () => room.service.beatsFor(room.channelThreadId),
    );
    final media = (beats!.last['attachments']! as List).cast<Map>();
    expect(media, hasLength(1));
    expect(media.single['mimeType'], 'image/png');
    expect(
      (media.single['path']! as String).startsWith('assets/'),
      isTrue,
      reason: 'the staged entry path stays world-relative (v1.1)',
    );

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
