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
    required this.selected,
    super.key,
  });
  final ProjectModel project;
  final bool selected;
  final ValueChanged<ProjectModel> onTap;
  final ValueChanged<ProjectModel> onRemove;

  String createTitle(final BuildContext context) => project.getTitle(context);

  @override
  Widget build(final BuildContext context) {
    final theme = context.theme;
    final effectiveLeadingIcon = Padding(
      padding: const EdgeInsets.only(top: 3),
      child: project.map(
        idea: (final idea) => SizedBox.square(
          dimension: 14,
          child: IconIdea(
            size: 14,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        changelog: (final changelog) => SizedBox.square(
          dimension: 14,
          child: Icon(
            Icons.newspaper,
            size: 12.5,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        note: (final note) => SizedBox.square(
          dimension: 14,
          child: Icon(
            Icons.book_rounded,
            size: 12.5,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ),
    );

    return DismissibleTile(
      dismissibleKey: ValueKey(project.id),
      // confirmDismiss: (final direction) async {
      //   if (direction != DismissDirection.startToEnd) return false;
      //   return onRemoveConfirm(project);
      // },
      onDismissed: () => onRemove(project),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        onTap: () => onTap(project),
        selected: selected,
        title: Stack(
          children: [
            effectiveLeadingIcon,
            HeroId(
              id: project.id.value,
              type: HeroIdTypes.projectTitle,
              child: Text(
                '      ${createTitle(context)}',
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
