import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view.dart';
import 'package:lastanswer/note/note_view.dart';
import 'package:lastanswer/settings/views/changelog_view.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectContainer =
        context.select<OpenedProjectNotifier, LoadableContainer<ProjectModel>>(
      (final c) => c.value,
    );
    if (projectContainer.isLoading) {
      return const UiCircularProgress();
    }

    final id = projectContainer.value.id;
    return projectContainer.value.map(
      idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
      note: (final note) => _AdaptiveView(
        appBar: const _ProjectViewAppBar(),
        child: NoteView(note: note, key: ValueKey(id)),
      ),
      changelog: (final changelog) => const _AdaptiveView(
        appBar: _ChangelogViewAppBar(),
        child: ChangelogView(),
      ),
    );
  }
}

class _AdaptiveView extends StatelessWidget {
  const _AdaptiveView({required this.child, required this.appBar, super.key});
  final Widget appBar;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (screenLayout.small) appBar else const Gap(42),
        Expanded(child: child),
      ],
    );
  }
}

class _ProjectViewAppBar extends StatelessWidget {
  const _ProjectViewAppBar({super.key});

  @override
  Widget build(final BuildContext context) => BackTextUniversalAppBar(
        onBack: () => context.go(ScreenPaths.home),
        titleStr: '',
        useBackButton: true,
      );
}

class _ChangelogViewAppBar extends StatelessWidget {
  const _ChangelogViewAppBar({super.key});

  @override
  Widget build(final BuildContext context) => BackTextUniversalAppBar(
        onBack: () => context.go(ScreenPaths.home),
        titleStr: context.l10n.changeLog,
        useBackButton: true,
      );
}
