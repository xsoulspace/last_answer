import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_route.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

class SavedProjects implements ProjectsRepository {
  final records = <String, Future<ProjectModel?>>{};
  @override
  Future<ProjectModel?> getById({required ProjectModelId id}) =>
      records[id.value] ?? Future.value();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SelectedProject extends ValueNotifier<LoadableContainer<ProjectModel>>
    implements OpenedProjectNotifier {
  SelectedProject() : super(LoadableContainer.loaded(ProjectModel.emptyNote));
  @override
  void onPopProject({ProjectModelId? expectedProjectId}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProjectModelDoc saved(String id) =>
    (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
      id: ProjectModelId(id),
      title: 'Saved qualification',
      agent: const AgentDocModel(
        backend: 'openai_chatgpt_plan',
        workspaces: ['/isolated/qualification'],
      ),
    );

Future<GoRouter> mount(
  WidgetTester tester,
  SavedProjects records,
  SelectedProject opened, {
  Widget Function(ProjectModel project)? view,
}) async {
  final router = GoRouter(
    initialLocation: '/home/d/one',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Text('home')),
      GoRoute(
        path: '/home/d/:docId',
        builder: (_, state) => ProjectRoute(
          projectId: state.pathParameters['docId']!,
          projectType: ProjectTypes.doc,
          builder: (_, project) =>
              view?.call(project) ?? Text('selected:${project.id.value}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ProjectsRepository>.value(value: records),
        ChangeNotifierProvider<OpenedProjectNotifier>.value(value: opened),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  addTearDown(router.dispose);
  addTearDown(opened.dispose);
  return router;
}

void main() {
  testWidgets('same address refresh retains the stateful view', (tester) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(saved('one'));
    final opened = SelectedProject();
    var disposed = 0;
    final router = await mount(
      tester,
      records,
      opened,
      view: (project) =>
          ViewProbe(id: project.id.value, onDispose: () => disposed++),
    );
    await tester.pumpAndSettle();
    router.go('/home/d/one?query=changed');
    await tester.pumpAndSettle();
    router.refresh();
    await tester.pumpAndSettle();
    expect(disposed, 0);
    expect(find.text('selected:one'), findsOneWidget);
  });
  testWidgets('a singleton selection change cannot change the addressed view', (
    tester,
  ) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(saved('one'));
    final opened = SelectedProject();
    await mount(tester, records, opened);
    await tester.pumpAndSettle();
    opened.value = LoadableContainer.loaded(saved('two'));
    await tester.pumpAndSettle();
    expect(find.text('selected:one'), findsOneWidget);
    expect(find.text('selected:two'), findsNothing);
  });
  testWidgets('mismatched repository identity is refused', (tester) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(saved('two'));
    final opened = SelectedProject();
    await mount(tester, records, opened);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project_route.unavailable')), findsOneWidget);
    expect(find.textContaining('selected:'), findsNothing);
  });
  testWidgets('direct document route restores saved backend and workspace', (
    tester,
  ) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(saved('one'));
    final opened = SelectedProject();
    await mount(tester, records, opened);
    await tester.pumpAndSettle();
    expect(find.text('selected:one'), findsOneWidget);
    final doc = opened.value.value as ProjectModelDoc;
    expect(doc.agent!.backend, 'openai_chatgpt_plan');
    expect(doc.agent!.workspaces, ['/isolated/qualification']);
  });

  testWidgets('missing or wrong-kind address never renders another selection', (
    tester,
  ) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(
        ProjectModel.emptyNote.copyWith(id: const ProjectModelId('one')),
      );
    final opened = SelectedProject();
    final priorId = opened.value.value.id;
    final router = await mount(tester, records, opened);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project_route.unavailable')), findsOneWidget);
    expect(opened.value.value.id, priorId);
    router.go('/home/d/missing');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project_route.unavailable')), findsOneWidget);
    expect(opened.value.value.id, priorId);
    expect(find.textContaining('selected:'), findsNothing);
  });

  testWidgets('late lookup cannot replace a newer addressed item', (
    tester,
  ) async {
    final late = Completer<ProjectModel?>();
    final records = SavedProjects()
      ..records['one'] = late.future
      ..records['two'] = Future.value(saved('two'));
    final opened = SelectedProject();
    final router = await mount(tester, records, opened);
    router.go('/home/d/two');
    await tester.pumpAndSettle();
    late.complete(saved('one'));
    await tester.pumpAndSettle();
    expect(opened.value.value.id.value, 'two');
    expect(find.text('selected:two'), findsOneWidget);
  });

  testWidgets('imperative push and back restore their addressed selection', (
    tester,
  ) async {
    final records = SavedProjects()
      ..records['one'] = Future.value(saved('one'))
      ..records['two'] = Future.value(saved('two'));
    final opened = SelectedProject();
    final router = await mount(tester, records, opened);
    await tester.pumpAndSettle();
    unawaited(router.push('/home/d/two'));
    await tester.pumpAndSettle();
    expect(find.text('selected:two'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('selected:one'), findsOneWidget);
    expect(opened.value.value.id.value, 'one');
  });
}

class ViewProbe extends StatefulWidget {
  const ViewProbe({required this.id, required this.onDispose, super.key});
  final String id;
  final VoidCallback onDispose;
  @override
  State<ViewProbe> createState() => _ViewProbeState();
}

class _ViewProbeState extends State<ViewProbe> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('selected:${widget.id}');
}
