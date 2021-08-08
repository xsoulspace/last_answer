part of idea_project;

class IdeaProjectScreen extends StatelessWidget {
  const IdeaProjectScreen({
    required final this.projectId,
    final Key? key,
  }) : super(key: key);
  final ProjectId projectId;
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProjectId>('projectId', projectId));
  }
}
