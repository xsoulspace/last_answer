
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/surfaces.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'hermetic_world_state.dart';

/// Phase 2 — semantics and keyboard as first-class chrome (redesign
/// §2.3): the ⌘K palette over the unified search, the shell-level focus
/// reclaim (the `⌘T handled:false` class), and the acceptance gate — a
/// semantic snapshot of the idle shell lists every rail entry, every
/// open tab and the status edge.
Future<void> _pumpShell(
  final WidgetTester tester, {
  final WorldStateService? worldState,
}) async {
  final world = worldState ?? hermeticWorldState();
  await world.refresh();
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final _) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: AppShell(worldState: world, child: const CenterTabsArea()),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  addTearDown(world.dispose);
}

Future<void> _pressCtrlKey(
  final WidgetTester tester,
  final LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
  await tester.pump();
}

void main() {
  late Directory devicePin;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    devicePin = Directory.systemTemp.createTempSync('la_palette_home_');
    RealmWorld.debugDeviceHome = devicePin.path;
  });

  tearDown(() {
    RealmWorld.debugDeviceHome = null;
    devicePin.deleteSync(recursive: true);
  });

  group('the ⌘K command palette', () {
    testWidgets('ctrl-K opens it; typing filters; enter runs the pick', (
      final tester,
    ) async {
      await _pumpShell(tester);
      await _pressCtrlKey(tester, LogicalKeyboardKey.keyK);
      expect(
        find.byKey(const ValueKey('shell.commandPalette')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('palette.query')),
        'models',
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('palette.entry.view.models')),
        findsOneWidget,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // The pick ran: the Models surface hosts as a tab, palette closed.
      expect(find.byKey(const ValueKey('view.tab.models')), findsOneWidget);
      expect(find.byKey(const ValueKey('shell.commandPalette')), findsNothing);
    });

    testWidgets('a hardware Enter runs the selected pick', (
      final tester,
    ) async {
      await _pumpShell(tester);
      await _pressCtrlKey(tester, LogicalKeyboardKey.keyK);
      await tester.enterText(
        find.byKey(const ValueKey('palette.query')),
        'models',
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.byKey(const ValueKey('view.tab.models')), findsOneWidget);
      expect(find.byKey(const ValueKey('shell.commandPalette')), findsNothing);
    });

    testWidgets('escape closes without running anything', (final tester) async {
      await _pumpShell(tester);
      await _pressCtrlKey(tester, LogicalKeyboardKey.keyK);
      expect(
        find.byKey(const ValueKey('shell.commandPalette')),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byKey(const ValueKey('shell.commandPalette')), findsNothing);
      expect(find.byKey(const ValueKey('view.tab.models')), findsNothing);
    });

    testWidgets('the action bar search button is the palette trigger', (
      final tester,
    ) async {
      // The search button rides the action bar (always rendered at
      // desktop widths — the expanded-rail gate retired with the rail).
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpShell(tester);
      await tester.tap(find.byKey(const ValueKey('rail.search')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('shell.commandPalette')),
        findsOneWidget,
      );
    });
  });

  group('the shell-level focus', () {
    testWidgets('a stranded focus never strands the strip keyboard', (
      final tester,
    ) async {
      await _pumpShell(tester);
      // The real failure mode: a focused field dies with its overlay
      // (the palette closes), focus falls to nothing — the shell's
      // anchor must reclaim it or the strip keyboard goes deaf.
      await _pressCtrlKey(tester, LogicalKeyboardKey.keyK);
      expect(
        find.byKey(const ValueKey('shell.commandPalette')),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byKey(const ValueKey('shell.commandPalette')), findsNothing);

      // v4: ⌘T opens the PICKER MENU (the picker-as-tab retired).
      await _pressCtrlKey(tester, LogicalKeyboardKey.keyT);
      expect(find.byKey(const ValueKey('newtab.page')), findsOneWidget);
    });
  });

  group('the semantic snapshot (the agent contract)', () {
    testWidgets('the idle shell lists rail entries, tabs and the edge', (
      final tester,
    ) async {
      final handle = tester.ensureSemantics();
      // The expanded rail (search field included) is part of the
      // snapshot contract.
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpShell(tester);

      final labels = <String>[];
      void visit(final SemanticsNode node) {
        if (node.label.isNotEmpty) labels.add(node.label);
        node.visitChildren((final child) {
          visit(child);
          return true;
        });
      }

      final root =
          tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
      expect(root, isNotNull);
      visit(root!);

      // Semantics nodes merge a label with its hint, so the snapshot
      // is matched as one document, key-name by key-name.
      final snapshot = labels.join('\n');
      // Every rail entry (the activity bar)…
      for (final id in const [
        kConversationsSurfaceId,
        kBoardsSurfaceId,
        kFilesystemSurfaceId,
        kBrowserSurfaceId,
        kInspectorSurfaceId,
        kThreadsSurfaceId,
        kTerminalSurfaceId,
        kPeopleSurfaceId,
      ]) {
        expect(snapshot, contains('rail.view.$id'));
      }
      // …the open tab…
      expect(snapshot, contains('view.tab.$kConversationsSurfaceId'));
      expect(snapshot, contains('view.strip.add.0'));
      // …the search trigger…
      expect(snapshot, contains('rail.search'));
      // …and the status edge, segment by segment.
      for (final key in const [
        'edge.world',
        'edge.backend',
        'edge.mesh',
        'edge.attention',
      ]) {
        expect(snapshot, contains(key));
      }
      handle.dispose();
    });
  });
}
