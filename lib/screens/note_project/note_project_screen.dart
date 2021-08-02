part of note_project;

class NoteProjectScreen extends StatelessWidget {
  const NoteProjectScreen({
    required final this.project,
    final Key? key,
  }) : super(key: key);
  final NoteProject project;
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<NoteProject>('project', project));
  }
}
