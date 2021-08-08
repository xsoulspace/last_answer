part of note_project;

class NoteProjectScreen extends StatelessWidget {
  const NoteProjectScreen({
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
