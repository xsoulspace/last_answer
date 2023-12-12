import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_widgets/project_widgets.dart';
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
    final screenLayout = ScreenLayout.of(context);
    return projectContainer.value.map(
      idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
      note: (final note) => Column(
        children: [
          if (screenLayout.small) const ProjectViewAppBar() else const Gap(42),
          Expanded(child: NoteView(note: note, key: ValueKey(id))),
        ],
      ),
    );
  }
}
