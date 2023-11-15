import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:provider/provider.dart';

class NoteProjectScreen extends StatelessWidget {
  const NoteProjectScreen({
    required this.delegate,
    super.key,
  });
  final NoteProjectViewDelegate delegate;
  @override
  Widget build(final BuildContext context) => NoteProjectViewProvider(
        delegate: delegate,
        builder: (final context) => NoteProjectView(
          delegate: delegate,
        ),
      );
}

class NoteProjectViewProvider extends StatefulWidget {
  const NoteProjectViewProvider({
    required this.builder,
    required this.delegate,
    super.key,
  });
  final WidgetBuilder builder;
  final NoteProjectViewDelegate delegate;

  @override
  State<NoteProjectViewProvider> createState() =>
      _NoteProjectViewProviderState();
}

class _NoteProjectViewProviderState extends State<NoteProjectViewProvider>
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
        builder: (final context, final child) => widget.builder(context),
      );
}
