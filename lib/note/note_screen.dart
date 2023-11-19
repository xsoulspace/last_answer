import 'package:lastanswer/common_imports.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({
    required this.note,
    super.key,
  });
  final ProjectModelNote note;
  @override
  Widget build(final BuildContext context) {
    final projectNotifier = context.read<OpenedProjectNotifier>();
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: PlatformInfo.isNativeWebDesktop
            ? const EdgeInsets.only(bottom: 48)
            : null,
        child: TextFormField(
          expands: true,
          initialValue: note.note,
          maxLines: null,
          decoration: const InputDecoration.collapsed(
            hintText: 'Start a note:)',
          ),
          textAlignVertical: TextAlignVertical.bottom,
          onChanged: (final value) => projectNotifier.updateProject(
            note.copyWith(
              note: value,
              updatedAt: DateTime.now(),
            ),
          ),
        ),
      ),
    );
  }
}
