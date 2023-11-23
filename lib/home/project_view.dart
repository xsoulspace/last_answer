import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/widgets/widgets.dart';
import 'package:lastanswer/idea/idea_view.dart';
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
    final id = projectContainer.value.id;

    return Column(
      children: [
        const ProjectViewAppBar(),
        Expanded(
          child: projectContainer.value.map(
            idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
            note: (final note) => NoteView(note: note, key: ValueKey(id)),
          ),
        ),
      ],
    );
  }
}
