import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_screen.dart';
import 'package:lastanswer/note/note_view.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectContainer =
        context.select<OpenedProjectNotifier, LoadableContainer<ProjectModel>>(
      (final c) => c.value,
    );
    if (projectContainer.isLoading) {
      return const CircularProgressIndicator.adaptive();
    }
    return projectContainer.value.map(
      idea: (final idea) => IdeaScreen(idea: idea),
      note: (final note) => NoteView(note: note),
    );
  }
}
