import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/note_view_bloc.dart';
import 'package:lastanswer/pack_app/widgets/project_text_field.dart';
import 'package:lastanswer/pack_note/widgets/note_project_side_actionbar.dart';

class NoteView extends StatefulWidget {
  const NoteView({
    required this.note,
    super.key,
  });
  final ProjectModelNote note;
  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final _) => NoteViewBloc(
          dto: NoteViewBlocDto(
            initialNote: widget.note,
            tickerProvider: this,
            context: context,
          ),
        ),
        builder: (final context, final child) => const NoteViewBody(),
      );
}

class NoteViewBody extends StatelessWidget {
  const NoteViewBody({super.key});
  @override
  Widget build(final BuildContext context) {
    final projectNotifier = context.read<OpenedProjectNotifier>();
    final bloc = context.watch<NoteViewBloc>();
    final isKeyboardClosed = !bloc.specialEmojiController.value.isKeyboardOpen;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ProjectTextField(
                  hintText: context.l10n.writeANote,
                  fillColor: Colors.transparent,
                  filled: false,
                  limit: int.tryParse(bloc.characterLimitController.value),
                  focusNode: bloc.focusNode,
                  endlessLines: true,
                  focusOnInit: bloc.dto.initialNote.id.isEmpty ||
                      PlatformInfo.isNativeWebDesktop,
                  onSubmit: bloc.onSubmit,
                  controller: bloc.noteController,
                  undoController: bloc.undoController,
                ),
              ),
              const NoteProjectSideActionBar(),
            ],
          ),
        ),
        if (PlatformInfo.isNativeWebDesktop) const Gap(48),
        if (isKeyboardClosed) const BottomSafeArea(),
      ],
    );
  }
}
