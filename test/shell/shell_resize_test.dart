// The drag-resize law's tests (owner request 2026-11-18): the pane
// groups' seams and the docked rooms column's right edge are drag
// handles, and their widths persist through the shell's local
// SharedPreferences API (`shell.pane.weights.v1`,
// `shell.rooms.width.v1`) beside the layout document.
//
// The lanes mirror app_shell_test.dart's hermetic pump (a REAL
// service whose world start fails honestly in the test binding, a
// hermetic WorldStateService, the mocked SharedPreferences): the
// workspace projection for the pane-seam drags, the chat-first
// projection for the rooms-column width.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_shell/app_shell.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';
import 'package:lastanswer/ui_workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import 'hermetic_world_state.dart';

/// A projects notifier fake whose real pager holds zero items — enough
/// for the document surfaces to render honestly empty (the
/// app_shell_test fake, mirrored).
class _IdleProjects extends ValueNotifier<ProjectsNotifierState>
    implements ProjectsNotifier {
  _IdleProjects() : super(const ProjectsNotifierState());

  @override
  final projectsPagedController = ProjectsPagedController(
    requestBuilder: _IdleRequests(),
  );

  @override
  Future<void> dispose() async => super.dispose();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IdleRequests extends ProjectsPagedDataRequestsBuilder {
  _IdleRequests()
    : super(
        onLoadData: (_) async => const PagingControllerPageModel(
          values: <ProjectModel>[],
          currentPage: 1,
          pagesCount: 1,
        ),
      );
}

Future<void> _pumpShell(final WidgetTester tester) async {
  final resolved = RealmChatService();
  final resolvedWorld = hermeticWorldState();
  // The service's world start fails for real (path_provider has no
  // plugin in the test binding) — started outside the tree so the
  // settled state is deterministic (the app_shell_test law).
  await tester.runAsync(resolved.ensureReady);
  await tester.pumpWidget(
    // The production DI composition's slice (the app_shell_test
    // harness): the registry + workspaces notifiers the surfaces read.
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsNotifier>.value(
            value: _IdleProjects(),
          ),
          ChangeNotifierProvider<WorkspaceNotifier>.value(
            value: WorkspaceNotifier(storeLoader: () async => null),
          ),
        ],
        child: MaterialApp(
          // The kit overlay host (LaTooltip/LaMenuAnchor need a Portal).
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: AppShell(
              service: resolved,
              worldState: resolvedWorld,
              child: const CenterTabsArea(),
            ),
          ),
        ),
      ),
    ),
  );
  // Flush the initState `ensureReady` no-op and the not-ready
  // progress indicator's animation timers (the app_shell_test pumps).
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
}

double _stripWidth(final WidgetTester tester, final int group) =>
    tester.getSize(find.byKey(ValueKey('view.strip.$group'))).width;

/// The strip width a weight share produces: the group column's
/// `Expanded` share of the panes row (the window minus the 56px rail)
/// minus the group's own two 6px edge zones. `weights` are relative —
/// only the ratio matters.
double _expectedStrip(final double weight, final List<double> weights) {
  const row = 800.0 - 56.0;
  var sum = 0.0;
  for (final w in weights) {
    sum += w;
  }
  return row * weight / sum - 12.0;
}

/// Opens [surfaceId] as a tab of group 0 through the strip's `+`
/// picker (the kind buttons retired — the picker is an open path).
Future<void> _openTab(
  final WidgetTester tester,
  final String entryKey,
) async {
  await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey(entryKey)));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'shell.rooms.docked': false,
    });
  });

  testWidgets('pane seam drag: the seam handle widens the left group '
      'against the right one, and the weights persist', (
    final tester,
  ) async {
    await _pumpShell(tester);
    // Split needs a non-world-face tab (the split refusal law).
    await _openTab(tester, 'newtab.entry.$kBoardsSurfaceId');
    await tester.tap(find.byKey(const ValueKey('view.group.split.0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.strip.1')), findsOneWidget);

    // Default weights are equal shares — the split landed half/half.
    expect(_stripWidth(tester, 0), closeTo(_expectedStrip(1, [1, 1]), 1.5));
    expect(_stripWidth(tester, 1), closeTo(_expectedStrip(1, [1, 1]), 1.5));

    await tester.drag(
      find.byKey(const ValueKey('pane.resize.0.right')),
      const Offset(80, 0),
    );
    await tester.pump();

    // +80 real px moved from group 1 to group 0 (a 1:1 seam follow at
    // equal weights).
    expect(
      _stripWidth(tester, 0),
      closeTo(_expectedStrip(1, [1, 1]) + 80, 1.5),
    );
    expect(
      _stripWidth(tester, 1),
      closeTo(_expectedStrip(1, [1, 1]) - 80, 1.5),
    );

    // The blob persists beside the layout document (the local API).
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPaneWeightsPrefsKey);
    expect(raw, isNotNull);
    final weights = (jsonDecode(raw!) as List).cast<double>();
    expect(weights, hasLength(2));
    expect(weights[0], greaterThan(weights[1]));
  });

  testWidgets('pane seam drag clamps at the minimum pane width', (
    final tester,
  ) async {
    await _pumpShell(tester);
    await _openTab(tester, 'newtab.entry.$kBoardsSurfaceId');
    await tester.tap(find.byKey(const ValueKey('view.group.split.0')));
    await tester.pump();

    await tester.drag(
      find.byKey(const ValueKey('pane.resize.0.right')),
      const Offset(-400, 0),
    );
    await tester.pump();

    expect(
      _stripWidth(tester, 0),
      closeTo(ShellTokens.minPaneWidth, 2),
    );
    // The right group takes the rest — never below the minimum either.
    expect(_stripWidth(tester, 1), greaterThan(ShellTokens.minPaneWidth));
  });  testWidgets('pane weights restore from the persisted blob', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'shell.rooms.docked': false,
      kViewLayoutPrefsKey: jsonEncode(<String, Object?>{
        'v': 4,
        'groups': <Object?>[
          <String, Object?>{
            'tabs': <String>[kConversationsSurfaceId, kBoardsSurfaceId],
            'active': 0,
          },
          // The people roster (the narrow-pane law's verified tier —
          // the documents header's fixed Row would overflow here, a
          // pre-existing narrowness gap outside this lane).
          <String, Object?>{
            'tabs': <String>[kPeopleSurfaceId],
            'active': 0,
          },
        ],
        'active': 0,
      }),
      kPaneWeightsPrefsKey: jsonEncode(<double>[1.5, 1]),
    });
    await _pumpShell(tester);

    // The 3:2 weights share the panes row; the group's own edge zones
    // come off the share.
    expect(_stripWidth(tester, 0), closeTo(_expectedStrip(1.5, [1.5, 1]), 2));
    expect(_stripWidth(tester, 1), closeTo(_expectedStrip(1, [1.5, 1]), 2));
  });

  testWidgets('split keeps the weight list aligned and a fold hands '
      'the folded width to the merge target', (final tester) async {
    await _pumpShell(tester);
    await _openTab(tester, 'newtab.entry.$kBoardsSurfaceId');
    await tester.tap(find.byKey(const ValueKey('view.group.split.0')));
    await tester.pump();
    // The split landed half/half of the source (the default 1.0
    // splits into 0.5 + 0.5).
    expect(_stripWidth(tester, 0), closeTo(_expectedStrip(1, [1, 1]), 1.5));
    expect(_stripWidth(tester, 1), closeTo(_expectedStrip(1, [1, 1]), 1.5));

    await tester.drag(
      find.byKey(const ValueKey('pane.resize.0.right')),
      const Offset(160, 0),
    );
    await tester.pump();
    expect(_stripWidth(tester, 0), greaterThan(_stripWidth(tester, 1)));

    // The fold merges group 1 back — and its width goes WITH the tabs
    // (the merge target keeps the combined width: one group fills the
    // row again).
    await tester.tap(find.byKey(const ValueKey('view.group.fold.1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.strip.1')), findsNothing);
    expect(_stripWidth(tester, 0), closeTo(_expectedStrip(1, [1]), 2));
  });

  testWidgets('rooms column width: the right-edge drag resizes and '
      'persists; the default is the token width', (final tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'shell.rooms.docked': true,
    });
    await _pumpShell(tester);

    final column = find.byKey(const ValueKey('shell.roomsColumn'));
    expect(tester.getSize(column).width, ShellTokens.contextColumnWidth);

    await tester.drag(
      find.byKey(const ValueKey('shell.rooms.resize')),
      const Offset(50, 0),
    );
    await tester.pump();

    expect(
      tester.getSize(column).width,
      ShellTokens.contextColumnWidth + 50,
    );
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getDouble(kRoomsColumnWidthPrefsKey),
      ShellTokens.contextColumnWidth + 50,
    );
  });

  testWidgets('rooms column width restores from the persisted blob', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'shell.rooms.docked': true,
      kRoomsColumnWidthPrefsKey: 320.0,
    });
    await _pumpShell(tester);
    expect(
      tester.getSize(find.byKey(const ValueKey('shell.roomsColumn'))).width,
      320.0,
    );
  });

  testWidgets('an out-of-band rooms width keeps the nearest honest '
      'width (the token band)', (final tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'shell.rooms.docked': true,
      kRoomsColumnWidthPrefsKey: 5000.0,
    });
    await _pumpShell(tester);
    expect(
      tester.getSize(find.byKey(const ValueKey('shell.roomsColumn'))).width,
      ShellTokens.maxRoomsColumnWidth,
    );
  });
}
