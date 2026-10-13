import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view_bloc.dart';
import 'package:lastanswer/note/note_view_bloc.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

class RecordedProjects extends ValueNotifier<ProjectsNotifierState>
    implements ProjectsNotifier {
  RecordedProjects() : super(const ProjectsNotifierState());
  final deleted = <ProjectModel>[];
  final updated = <ProjectModel>[];
  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  void deleteProject(ProjectModel project) => deleted.add(project);
  @override
  void updateEditingProject(
    ProjectModel project, {
    bool shouldMarkAsUpdated = true,
  }) => updated.add(project);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnusedUser implements UserNotifier {
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnusedTicker implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  for (final isNote in [true, false]) {
    testWidgets(
      '${isNote ? 'note' : 'idea'} confirmation deletes its displayed ID',
      (tester) async {
        final records = RecordedProjects();
        OpenedProjectNotifier? opened;
        late BuildContext actionContext;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ProjectsNotifier>.value(value: records),
              ListenableProvider<UserNotifier>.value(value: UnusedUser()),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: Builder(
                builder: (context) {
                  opened ??= OpenedProjectNotifier(context)
                    ..value = LoadableContainer.loaded(
                      ProjectModel.emptyNote.copyWith(
                        id: const ProjectModelId('selected-other'),
                      ),
                    );
                  return ChangeNotifierProvider<OpenedProjectNotifier>.value(
                    value: opened!,
                    child: Builder(
                      builder: (context) {
                        actionContext = context;
                        return const SizedBox();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        addTearDown(records.dispose);
        addTearDown(() => opened!.dispose());
        opened!.onPopProject(
          expectedProjectId: const ProjectModelId('displayed'),
        );
        expect(records.deleted, isEmpty);
        late Future<void> deleting;
        if (isNote) {
          final note = ProjectModel.emptyNote.copyWith(
            id: const ProjectModelId('displayed'),
            note: 'Displayed note',
          );
          final bloc = NoteViewBloc(
            dto: NoteViewBlocDto(
              initialNote: note,
              tickerProvider: UnusedTicker(),
              context: actionContext,
            ),
          );
          // This action initializes no keyboard/text/ticker resources. Close
          // eagerly allocated handles without initializing unrelated
          // lazy plugins.
          addTearDown(() {
            bloc.focusNode.dispose();
            bloc.undoController.dispose();
          });
          deleting = bloc.onRemove(actionContext);
        } else {
          final idea = ProjectModelIdea(
            id: const ProjectModelId('displayed'),
            title: 'Displayed idea',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          );
          final bloc = IdeaViewBloc(
            dto: IdeaViewBlocDto(initialIdea: idea, context: actionContext),
          );
          deleting = bloc.onDeleteIdea(actionContext);
        }
        await tester.pumpAndSettle();
        await tester.tap(
          find.textContaining(RegExp(r'^delete$', caseSensitive: false)),
        );
        await tester.pumpAndSettle();
        await deleting;
        expect(records.deleted.single.id.value, 'displayed');
        expect(opened!.value.value.id.value, 'selected-other');
        opened!.updateProject(records.deleted.single);
        expect(records.updated.single.id.value, 'displayed');
        expect(opened!.value.value.id.value, 'selected-other');
        opened!.onPopProject(
          expectedProjectId: const ProjectModelId('selected-other'),
        );
        expect(records.deleted.last.id.value, 'selected-other');
      },
    );
  }
}
