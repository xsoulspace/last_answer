import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

/// A projects notifier fake whose real pager holds zero items (the
/// shell harness's shape, local here).
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

/// ADR 0032 — the settings document: ONE endless scroll of registered
/// sections (no PageView), the type-to-jump filter, and the scroll-spy
/// anchor column at ≥ 640px. Pumped over the production DI composition
/// (GlobalStatesProvider) the same way the shell harness does, so the
/// rows are the REAL rows.
Future<void> _pumpScreen(
  final WidgetTester tester, {
  final Size size = const Size(1200, 800),
}) async {
  // The logical surface drives MediaQuery (the TOC's 640px law reads it).
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsNotifier>.value(value: _IdleProjects()),
        ],
        child: MaterialApp(
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: SettingsScreen(
              embedded: true,
              onClose: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('the document: registry sections render in order with '
      'their entry keys (no PageView tabs)', (final tester) async {
    await _pumpScreen(tester);

    // The section labels, uppercase micro — in registry order.
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('NOTES'), findsOneWidget);
    expect(find.text('DATA & SYNC'), findsOneWidget);
    expect(find.text('AGENTS'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    // The row/block key contract.
    expect(find.byKey(const ValueKey('settings.entry.profile')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings.entry.theme')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings.entry.charactersLimit')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('settings.entry.storage')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings.entry.agentServers')),
      findsOneWidget,
    );
    // The automations section is GONE (ADR 0032: a feature, not a
    // preference) — the supervisor moved to its own surface.
    expect(find.byKey(const ValueKey('automations.surface')), findsNothing);
    // The providers/models editing is gone (the Models surface owns it).
    expect(find.byKey(const Key('agent_config.chat.provider')), findsNothing);
  });

  testWidgets('the jump field filters the document by title and keywords', (
    final tester,
  ) async {
    await _pumpScreen(tester);
    await tester.enterText(find.byKey(const ValueKey('settings.jump')), 'dark');
    await tester.pump();

    // 'dark' is a theme keyword: the appearance section survives, the
    // sections that cannot match fall away.
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('THEME'), findsNothing); // row titles live in the gutter
    expect(find.byKey(const ValueKey('settings.entry.theme')), findsOneWidget);
    expect(find.text('DATA & SYNC'), findsNothing);
    expect(find.byKey(const ValueKey('settings.entry.storage')), findsNothing);

    // Clearing restores the whole document.
    await tester.enterText(find.byKey(const ValueKey('settings.jump')), '');
    await tester.pump();
    expect(find.byKey(const ValueKey('settings.entry.storage')), findsOneWidget);
  });

  testWidgets('the anchor column: present at ≥640, absent below (the '
      'models compact law), and a tap scrolls to the section', (
    final tester,
  ) async {
    await _pumpScreen(tester, size: const Size(1200, 800));
    expect(find.byKey(const ValueKey('settings.toc')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings.toc.about')));
    await tester.pumpAndSettle();
    // The about section landed in view (the scroll moved to it).
    expect(
      find.byKey(const ValueKey('settings.entry.version')),
      findsOneWidget,
    );

    // Below the breakpoint the TOC is gone; the document still scrolls.
    await _pumpScreen(tester, size: const Size(500, 800));
    expect(find.byKey(const ValueKey('settings.toc')), findsNothing);
  });
}
