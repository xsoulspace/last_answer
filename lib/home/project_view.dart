import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
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
    return projectContainer.value.map(
      idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
      note: (final note) => NoteView(note: note, key: ValueKey(id)),
    );
  }
}

class ProjectViewAppBar extends StatelessWidget {
  const ProjectViewAppBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    return AppBar(
      leading: screenLayout.small
          ? BackButton(onPressed: () => context.go(ScreenPaths.home))
          : null,
      automaticallyImplyLeading: false,
    );
  }
}
