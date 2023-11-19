import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

typedef ProjectSelectionChanged = void Function({
  required bool? selected,
  required ProjectModel project,
});

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required this.project,
    required this.onTap,
    required this.onRemove,
    required this.onRemoveConfirm,
    required this.themeDefiner,
    required this.isProjectActive,
    super.key,
  });
  final ProjectModel project;
  final bool isProjectActive;
  final ValueChanged<ProjectModel> onTap;
  final ValueChanged<ProjectModel> onRemove;
  final FutureBoolValueChanged<ProjectModel> onRemoveConfirm;
  final ThemeDefiner themeDefiner;

  String createTitle() => project.title;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final useContextTheme = themeDefiner.useContextTheme;
    final tileColor = useContextTheme ? theme.cardColor : Colors.transparent;
    Widget? effectiveLeadingIcon;

    if (project is IdeaProject) {
      effectiveLeadingIcon = const SizedBox(
        width: 14,
        child: Align(
          child: IconIdea(size: 14),
        ),
      );
    }

    double blurOpacity = 0;

    if (!useContextTheme) {
      if (isProjectActive) {
        blurOpacity = themeDefiner.useDarkTheme ? 0.3 : 0.8;
      } else {
        blurOpacity = themeDefiner.useDarkTheme ? 0.1 : 0.7;
      }
    }

    return DismissibleTile(
      dismissibleKey: ValueKey(project.id),
      // confirmDismiss: (final direction) async {
      //   if (direction != DismissDirection.startToEnd) return false;
      //   return onRemoveConfirm(project);
      // },
      onDismissed: () => onRemove(project),
      child: HeroId(
        id: project.id.value,
        type: HeroIdTypes.projectTitle,
        child: Stack(
          children: [
            if (!useContextTheme)
              Positioned.fill(
                child: Container().blurred(
                  colorOpacity: blurOpacity,
                  borderRadius: defaultBorderRadius,
                ),
              ),
            ListTile(
              dense: !useContextTheme,
              shape: RoundedRectangleBorder(
                borderRadius: defaultBorderRadius,
              ),
              contentPadding: project is IdeaProject
                  ? const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(left: 15)
                  : null,
              minLeadingWidth: project is IdeaProject ? 0 : null,
              minVerticalPadding: project is NoteProject ? 12 : null,
              leading: effectiveLeadingIcon,
              onTap: () => onTap(project),
              tileColor: tileColor,
              selected: isProjectActive,
              title: Stack(
                children: [
                  if (project is NoteProject)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Icon(
                        Icons.book_rounded,
                        size: 12.5,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                    ),
                  Text(
                    createTitle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
