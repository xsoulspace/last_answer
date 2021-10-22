part of widgets;

typedef BoolValueChanged<T> = bool Function(T value);
typedef FutureBoolValueChanged<T> = Future<bool> Function(T value);

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required final this.project,
    required final this.onSelected,
    required final this.onTap,
    required final this.checkSelection,
    required final this.onRemove,
    required final this.onRemoveConfirm,
    final Key? key,
  }) : super(key: key);
  final BasicProject project;
  final BoolValueChanged<BasicProject> checkSelection;
  final ProjectSelectionChanged onSelected;
  final ValueChanged<BasicProject> onTap;
  final ValueChanged<BasicProject> onRemove;
  final FutureBoolValueChanged<BasicProject> onRemoveConfirm;
  @override
  Widget build(final BuildContext context) {
    return DismissibleTile(
      dismissibleKey: ValueKey(project.id),
      confirmDismiss: (final direction) async {
        if (direction != DismissDirection.startToEnd) return false;
        return onRemoveConfirm(project);
      },
      onDismissed: (final direction) {
        if (direction != DismissDirection.startToEnd) return;
        onRemove(project);
      },
      child: HeroId(
        id: project.id,
        type: HeroIdTypes.projectTitle,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
          contentPadding: project is IdeaProject
              ? const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 15)
              : null,
          minLeadingWidth: project is IdeaProject ? 0 : null,
          minVerticalPadding: project is NoteProject ? 12 : null,
          leading: project is IdeaProject
              ? SizedBox(
                  width: 14,
                  child: Align(
                    alignment: Alignment.center,
                    child: const IconIdea(size: 14),
                  ),
                )
              : null,
          onTap: () => onTap(project),
          tileColor: Theme.of(context).cardColor,
          title: Text(project.title),
          // trailing: ,
          // TODO(arenukvern): add checkbox to mark project as completed
          // trailing: Checkbox(
          //   value: checkSelection(project),
          //   onChanged: (final selected) =>
          //       onSelected(selected: selected, project: project),
          //   shape: const CircleBorder(),
          // ),
        ),
      ),
    );
  }
}
