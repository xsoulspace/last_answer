import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_note/note_view.dart';

class NoteProjectScreen extends StatefulWidget {
  const NoteProjectScreen({
    required this.delegate,
    super.key,
  });
  final NoteProjectViewDelegate delegate;

  @override
  State<NoteProjectScreen> createState() => _NoteProjectScreenState();
}

class _NoteProjectScreenState extends State<NoteProjectScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (final context) => NoteProjectViewBloc(
              delegate: widget.delegate,
              dto: NoteProjectViewStateDto(
                context: context,
                tickerProvider: this,
                noteId: widget.delegate.noteId,
              ),
            ),
          ),
        ],
        builder: (final context, final child) => const NoteProjectView(),
      );
}
