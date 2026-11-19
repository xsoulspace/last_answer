import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/legacy_kit/legacy_kit.dart';

typedef ProjectSelectionChanged =
    void Function({required bool? selected, required ProjectModel project});

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
    final laUi = context.laUi;
    final iconColor = laUi.accent.withValues(alpha: 0.5);
    final effectiveLeadingIcon = Padding(
      padding: const EdgeInsets.only(top: 3),
      child: project.map(
        idea: (final idea) => SizedBox.square(
          dimension: 14,
          child: Assets.icons.idea.svg(
            height: 14,
            width: 14,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        changelog: (final changelog) => SizedBox.square(
          dimension: 14,
          child: Icon(Icons.newspaper, size: 12.5, color: iconColor),
        ),
        note: (final note) => SizedBox.square(
          dimension: 14,
          child: Icon(Icons.book_rounded, size: 12.5, color: iconColor),
        ),
        doc: (final doc) => SizedBox.square(
          dimension: 14,
          child: Icon(
            switch (doc.formatId) {
              DocFormatIds.chat => Icons.forum_outlined,
              DocFormatIds.code => Icons.code,
              _ => Icons.article_outlined,
            },
            size: 12.5,
            color: iconColor,
          ),
        ),
      ),
    );

    return DismissibleTile(
      canDismiss: project.type != ProjectTypes.systemChangelog,
      dismissibleKey: ValueKey(project.id),
      // confirmDismiss: (final direction) async {
      //   if (direction != DismissDirection.startToEnd) return false;
      //   return onRemoveConfirm(project);
      // },
      onDismissed: () => onRemove(project),
      child: LaRow(
        onTap: () => onTap(project),
        selected: selected,
        radius: defaultBorderRadius,
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
