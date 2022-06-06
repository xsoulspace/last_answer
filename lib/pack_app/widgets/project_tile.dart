part of pack_app;

typedef BoolValueChanged<T> = bool Function(T value);
typedef FutureBoolValueChanged<T> = Future<bool> Function(T value);

typedef ProjectSelectionChanged = void Function({
  required bool? selected,
  required BasicProject project,
});

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required final this.project,
    required final this.onTap,
    required final this.onRemove,
    required final this.onRemoveConfirm,
    required final this.themeDefiner,
    required final this.isProjectActive,
    final Key? key,
  }) : super(key: key);
  final BasicProject project;
  final bool isProjectActive;
  final ValueChanged<BasicProject> onTap;
  final ValueChanged<BasicProject> onRemove;
  final FutureBoolValueChanged<BasicProject> onRemoveConfirm;
  final ThemeDefiner themeDefiner;

  String createTitle() =>
      (project is NoteProject ? '      ' : '') + project.title;

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

    double blurOpacity = 0.0;

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
        id: project.id,
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
                  ? const EdgeInsets.only(left: 15, right: 16)
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
                            theme.textTheme.bodyText2?.color?.withOpacity(0.5),
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
