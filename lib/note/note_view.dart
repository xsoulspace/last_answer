import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/home.dart';
import 'package:lastanswer/note/note_view_bloc.dart';
import 'package:lastanswer/note/widgets/note_project_side_actionbar.dart';

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
  Widget build(final BuildContext context) => PopScope(
        onPopInvoked: (final _) =>
            context.read<OpenedProjectNotifier>().onPopProject(),
        child: ChangeNotifierProvider(
          create: (final _) => NoteViewBloc(
            dto: NoteViewBlocDto(
              initialNote: widget.note,
              tickerProvider: this,
              context: context,
            ),
          ),
          builder: (final context, final child) => const NoteViewBody(),
        ),
      );
}

class NoteViewBody extends StatelessWidget {
  const NoteViewBody({super.key});
  @override
  Widget build(final BuildContext context) {
    final bloc = context.watch<NoteViewBloc>();
    final isSpecialEmojiKeyboardOpen =
        bloc.specialEmojiController.value.isKeyboardOpen;
    return SpecialEmojiKeyboardProvider(
      controller: bloc.specialEmojiController,
      builder: (final context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: HeroId(
                    id: bloc.note.id.value,
                    type: HeroIdTypes.projectTitle,
                    child: ProjectTextField(
                      hintText: context.l10n.writeANote,
                      filled: false,
                      hasBorder: false,
                      contentPadding: const EdgeInsets.only(left: 24),
                      limit: int.tryParse(bloc.characterLimitController.value),
                      focusNode: bloc.focusNode,
                      endlessLines: true,
                      focusOnInit: bloc.dto.initialNote.note.isEmpty,
                      onSubmit: bloc.onSubmit,
                      controller: bloc.noteController,
                      undoController: bloc.undoController,
                    ),
                  ),
                ),
                if (PlatformInfo.isNativeWebDesktop) const Gap(48),
                if (!isSpecialEmojiKeyboardOpen) const BottomSafeArea(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: NoteProjectSideActionBar(),
          ),
        ],
      ),
    );
  }
}
