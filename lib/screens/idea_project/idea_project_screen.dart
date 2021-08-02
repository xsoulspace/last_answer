part of idea_project;

class IdeaProjectScreen extends StatelessWidget {
  const IdeaProjectScreen({
    required final this.project,
    final Key? key,
  }) : super(key: key);
  final IdeaProject project;
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IdeaProject>('project', project));
  }
}
