import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/center_tabs.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/view_documents.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import 'hermetic_world_state.dart';

/// Phase 3a — the Documents view: the human document navigation. The
/// registry's page renders as the grid, a click opens the document as a
/// TAB of the Documents view through the route page's own doc→surface
/// map (embedded), and an unknown id renders an honest quiet note.
final _chatDoc = ProjectModel.doc(
  id: ProjectModelId('doc-chat-1'),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  formatId: DocFormatIds.chat,
  title: 'World chat',
);

final _agentDoc = ProjectModel.doc(
  id: ProjectModelId('doc-agent-1'),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  formatId: DocFormatIds.agent,
  title: 'Redesign notes',
);

/// A registry notifier whose page carries the two fixture docs (the
/// paging request builder is the repository seam; nothing touches IO).
final class _DocsProjects extends ValueNotifier<ProjectsNotifierState>
    implements ProjectsNotifier {
  _DocsProjects()
    : projectsPagedController = ProjectsPagedController(
        requestBuilder: ProjectsPagedDataRequestsBuilder(
          onLoadData: (_) async => PagingControllerPageModel(
            values: <ProjectModel>[_chatDoc, _agentDoc],
            currentPage: 1,
            pagesCount: 1,
          ),
        ),
      ),
      super(const ProjectsNotifierState());

  @override
  final ProjectsPagedController projectsPagedController;

  @override
  Future<void> dispose() async => super.dispose();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpShell(
  final WidgetTester tester, {
  final _DocsProjects? projects,
}) async {
  final world = hermeticWorldState();
  await world.refresh();
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsNotifier>.value(
            value: projects ?? _DocsProjects(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: AppShell(worldState: world, child: const CenterTabsArea()),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  addTearDown(world.dispose);
}

void main() {
  late Directory devicePin;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    devicePin = Directory.systemTemp.createTempSync('la_docs_home_');
    RealmWorld.debugDeviceHome = devicePin.path;
  });

  tearDown(() {
    RealmWorld.debugDeviceHome = null;
    devicePin.deleteSync(recursive: true);
  });

  testWidgets('the grid lists the registry page; a click opens the doc as '
      'a tab of the Documents view', (final tester) async {
    final projects = _DocsProjects();
    projects.projectsPagedController.pager.addListener(
      () => debugPrint(
        'PAGER NOTIFY items=${projects.projectsPagedController.items.length}',
      ),
    );
    await _pumpShell(tester, projects: projects);
    await tester.tap(find.byKey(const ValueKey('rail.view.documents')));
    await tester.pump();
    // The page fetch is real-async (the repository seam): let the event
    // loop turn land inside runAsync, then rebuild.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('documents.row.doc-chat-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('documents.row.doc-agent-1')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('documents.new')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('documents.row.doc-chat-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // The doc opened as a TAB of the documents view, hosted through the
    // route page's own map (a chat doc is the world conversation).
    expect(
      find.byKey(const ValueKey('view.tab.doc:doc-chat-1')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey('documents.host.doc-chat-1')),
      findsOneWidget,
    );
    expect(find.byType(WorldChatSurface), findsOneWidget);
    // The strip's title resolves through the registry, not the raw id.
    expect(find.text('World chat'), findsWidgets);
  });

  testWidgets('a doc tab the loaded page does not carry says so honestly', (
    final tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsNotifier>.value(
            value: _DocsProjects(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: const Scaffold(body: DocumentsTabHost(docId: 'ghost-doc')),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('documents.missing')), findsOneWidget);
  });
}
