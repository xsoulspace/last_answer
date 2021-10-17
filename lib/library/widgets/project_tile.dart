part of widgets;

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    required final this.project,
    required final this.onSelected,
    required final this.onTap,
    required final this.checkSelection,
    final Key? key,
  }) : super(key: key);
  final BasicProject project;
  final bool Function(BasicProject) checkSelection;
  final ProjectSelectionChanged onSelected;
  final ValueChanged<BasicProject> onTap;
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      onTap: () => onTap(project),
      tileColor: Theme.of(context).splashColor,
      title: Text(project.title),
      trailing: Checkbox(
        value: checkSelection(project),
        onChanged: (final selected) =>
            onSelected(selected: selected, project: project),
        shape: const CircleBorder(),
      ),
    );
  }
}
