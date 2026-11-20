/// Wave H — the PANE-INSTANCE law (the 2026-11-10 defect's regression
/// pin): WorldChatSurface rendered the service's GLOBAL active thread,
/// so two visible panes holding two different conversation tabs BOTH
/// showed the active thread — the strip's pill and the pane content
/// disagreed across groups. The fix under test: every conversation pane
/// renders ITS OWN thread (its surface id resolved through the
/// service's ONE `threadIdForSurface` helper), while the service's
/// active thread keeps following focus (the unread/receipts law).
///
/// Pinned here, over the REAL [RealmChatService] on a hermetic temp-dir
/// [RealmWorld] (the world_chat_messages_test house pattern):
/// (a) two pinned panes side by side render their own threads
///     SIMULTANEOUSLY — the defect's regression pin;
/// (b) the UNFOCUSED pane's composer sends into its OWN thread (the
///     journal is the oracle) while the active thread, the other pane's
///     tail and the service's selection stay untouched;
/// (c) a null-surfaceId surface still tracks the global active thread
///     (today's law, byte-identical);
/// (d) the channel meta row follows each pane's OWN channel.
library;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/ecs_plugins/conversation/conversation_spaces.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/ui_chat/world_chat_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fixture holder: two channel rooms, each with ONE human beat, and
/// the service left with channel A SELECTED (the active thread follows
/// focus — the right pane is the visible-but-unfocused one). Creation-
/// time tearDowns own the service and the temp dir ONCE (the shell
/// test-lane law); this holder never disposes anything itself.
final class _Channels {
  _Channels({required this.service, required this.alpha, required this.beta});

  final RealmChatService service;
  final ChannelInfo alpha;
  final ChannelInfo beta;

  String get alphaSurfaceId => 'channel:${alpha.channelId}';
  String get betaSurfaceId => 'channel:${beta.channelId}';
}

Future<_Channels> _openChannels(
  final WidgetTester tester,
  final String label,
) async {
  SharedPreferences.setMockInitialValues({});
  final pin = Directory.systemTemp.createTempSync('wc_pane_$label');
  RealmWorld.debugDeviceHome = pin.path;
  addTearDown(() {
    RealmWorld.debugDeviceHome = null;
    pin.deleteSync(recursive: true);
  });
  late final _Channels fixture;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('wc_pane_ws_');
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
    final alpha = await service.createChannel('alpha');
    expect(alpha, isNotNull, reason: service.error);
    await service.say('a-one'); // rides the selection: alpha
    final beta = await service.createChannel('beta');
    expect(beta, isNotNull, reason: service.error);
    await service.say('b-one'); // rides the selection: beta
    // Criterion 5's setup: the service's ACTIVE thread follows focus —
    // pin alpha. The pinned panes must render their own threads
    // regardless of which one holds this selection.
    service.selectThread(alpha!.threadId);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    fixture = _Channels(service: service, alpha: alpha, beta: beta!);
  });
  return fixture;
}

final Finder _leftPane = find.byKey(const ValueKey('pane.left'));
final Finder _rightPane = find.byKey(const ValueKey('pane.right'));

/// Pumps TWO WorldChatSurface instances side by side in a Row over ONE
/// service: channel A pinned on the left, channel B on the right. The
/// panes' own pure beatsFor reads ride the kernel store — they complete
/// in a runAsync window (settled BEFORE it, the fake-clock law), then a
/// pump lands the rebuild.
Future<void> _pumpTwoPanes(
  final WidgetTester tester,
  final _Channels fixture,
) async {
  await tester.binding.setSurfaceSize(const Size(1044, 768));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ChangeNotifierProvider<RealmChatService>.value(
      value: fixture.service,
      child: MaterialApp(
        // The kit overlay host (same shape as last_answer_app.dart):
        // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
        builder: (final context, final child) =>
            Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: KeyedSubtree(
                  key: const ValueKey('pane.left'),
                  child: WorldChatSurface(
                    service: fixture.service,
                    surfaceId: fixture.alphaSurfaceId,
                  ),
                ),
              ),
              Expanded(
                child: KeyedSubtree(
                  key: const ValueKey('pane.right'),
                  child: WorldChatSurface(
                    service: fixture.service,
                    surfaceId: fixture.betaSurfaceId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 400)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets(
    'a — two visible conversation panes render their OWN threads '
    'simultaneously (the defect regression pin)',
    (final tester) async {
      final fixture = await _openChannels(tester, 'two_panes');
      await _pumpTwoPanes(tester, fixture);

      // The service's active thread is A — that is the defect's point:
      // the RIGHT pane must not render it.
      expect(fixture.service.activeThreadId, fixture.alpha.threadId);

      final beatA1 = find.byKey(
        ValueKey('worldchat.beat.${fixture.alpha.threadId}#1'),
      );
      final beatB1 = find.byKey(
        ValueKey('worldchat.beat.${fixture.beta.threadId}#1'),
      );
      // SIMULTANEOUSLY: A's beat on the left, B's beat on the right —
      // and never a crossover (before the fix both panes showed A).
      expect(
        find.descendant(of: _leftPane, matching: beatA1),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _rightPane, matching: beatB1),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _leftPane, matching: beatB1),
        findsNothing,
      );
      expect(
        find.descendant(of: _rightPane, matching: beatA1),
        findsNothing,
      );

      // The beat texts and the channel names follow the same law (the
      // header AND the composer hint name the pane's own channel; the
      // OTHER channel's name appears nowhere in the pane).
      expect(
        find.descendant(of: _leftPane, matching: find.text('a-one')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _rightPane, matching: find.text('b-one')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _leftPane, matching: find.text('#alpha')),
        findsWidgets,
      );
      expect(
        find.descendant(of: _leftPane, matching: find.text('#beta')),
        findsNothing,
      );
      expect(
        find.descendant(of: _rightPane, matching: find.text('#beta')),
        findsWidgets,
      );
      expect(
        find.descendant(of: _rightPane, matching: find.text('#alpha')),
        findsNothing,
      );

      // The focused composer holds the scheduler law: unfocus + settle.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'b — the unfocused pane composer sends into ITS OWN thread; the '
    'active thread, the other pane and the selection stay untouched',
    (final tester) async {
      final fixture = await _openChannels(tester, 'send');
      await _pumpTwoPanes(tester, fixture);

      final rightComposer = find.descendant(
        of: _rightPane,
        matching: find.byKey(const ValueKey('worldchat.composer')),
      );
      await tester.enterText(rightComposer, 'hello-beta');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: _rightPane,
          matching: find.byKey(const ValueKey('worldchat.send')),
        ),
      );
      await tester.pump();
      // The say rides real journal IO — complete it in a runAsync
      // window (the world_chat_composer_test c house pattern).
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      // The right pane re-reads its OWN beats after the notify — a
      // second window for the pure read, then the rebuild lands.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The new beat renders in the RIGHT pane only.
      final beatB2 = find.byKey(
        ValueKey('worldchat.beat.${fixture.beta.threadId}#2'),
      );
      expect(
        find.descendant(of: _rightPane, matching: beatB2),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _rightPane,
          matching: find.text('hello-beta'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _leftPane, matching: find.text('hello-beta')),
        findsNothing,
      );
      // A's tail is unchanged on screen.
      expect(
        find.descendant(of: _leftPane, matching: find.text('a-one')),
        findsOneWidget,
      );

      // The JOURNAL is the oracle: B's thread grew, A's did not.
      await tester.runAsync(() async {
        final bTail = await fixture.service.beatsFor(fixture.beta.threadId);
        expect(
          bTail.map((final beat) => beat['text']).toList(),
          <String>['b-one', 'hello-beta'],
        );
        final aTail = await fixture.service.beatsFor(fixture.alpha.threadId);
        expect(
          aTail.map((final beat) => beat['text']).toList(),
          <String>['a-one'],
        );
      });

      // The focus law: sending from an unfocused pane never steals the
      // service's selection (unread/receipts follow focus).
      expect(fixture.service.activeThreadId, fixture.alpha.threadId);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'c — a null-surfaceId surface still tracks the service active '
    'thread (today law, byte-identical)',
    (final tester) async {
      final fixture = await _openChannels(tester, 'null_surface');
      await tester.pumpWidget(
        ChangeNotifierProvider<RealmChatService>.value(
          value: fixture.service,
          child: MaterialApp(
            // The kit overlay host (same shape as last_answer_app.dart):
            // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
            builder: (final context, final child) =>
                Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: WorldChatSurface(service: fixture.service),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The fixture left alpha selected: its cached tail renders.
      expect(find.text('a-one'), findsOneWidget);
      expect(find.text('b-one'), findsNothing);

      // Selecting beta swaps what the pane shows — it follows the
      // GLOBAL active thread (the null-surfaceId contract).
      await tester.runAsync(() async {
        fixture.service.selectThread(fixture.beta.threadId);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      expect(find.text('b-one'), findsOneWidget);
      expect(find.text('a-one'), findsNothing);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'd — the channel meta row follows each pane own channel',
    (final tester) async {
      final fixture = await _openChannels(tester, 'meta');
      await _pumpTwoPanes(tester, fixture);

      // Both panes are channel rooms: EXACTLY ONE meta row each (the
      // row used to render the active thread's channel in both).
      for (final pane in <Finder>[_leftPane, _rightPane]) {
        for (final key in const [
          'worldchat.meta.perms',
          'worldchat.meta.members',
          'worldchat.meta.info',
        ]) {
          expect(
            find.descendant(
              of: pane,
              matching: find.byKey(ValueKey(key)),
            ),
            findsOneWidget,
            reason: key,
          );
        }
      }

      // The RIGHT pane's meta row is BETA's: its info dialog names
      // #beta and carries beta's thread id (asserted inside the dialog
      // — a dialog is a route, never a pane descendant).
      await tester.tap(
        find.descendant(
          of: _rightPane,
          matching: find.byKey(const ValueKey('worldchat.meta.info')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final dialog = find.byKey(
        const ValueKey('worldchat.meta.info.dialog'),
      );
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('#beta')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('#alpha')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.text(fixture.beta.threadId),
        ),
        findsOneWidget,
      );

      // Close and settle the route's exit animation (the dialog law:
      // settle before any following runAsync window / test end).
      await tester.tap(
        find.byKey(const ValueKey('worldchat.meta.info.close')),
      );
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
