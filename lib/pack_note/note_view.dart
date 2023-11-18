import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/widgets/note_project_side_actionbar.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit_state.dart';

part 'note_view_bloc.dart';

class NoteProjectViewDelegate {
  const NoteProjectViewDelegate({
    required this.noteId,
    required this.onBack,
    required this.onGoHome,
    required this.checkIsProjectActive,
  });
  final ProjectModelId noteId;
  final ValueChanged<ProjectModelNote> onBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;
}

class NoteProjectView extends StatelessWidget {
  const NoteProjectView({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);
    final bloc = context.watch<NoteProjectViewBloc>();
    double? appBarHeight;
    if (Platform.isMacOS) {
      appBarHeight = null;
    } else {
      appBarHeight = screenLayout.small ? 40 : 30;
    }
    final note = bloc.note;
    final specialEmojiController = bloc.specialEmojiController;

    return Scaffold(
      backgroundColor: theme.canvasColor,
      restorationId: 'notes/${bloc.dto.noteId.value}',
      resizeToAvoidBottomInset: false,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        height: appBarHeight,
        screenLayout: screenLayout,
        titleStr: '',
        onBack: bloc.onBack,
      ),
      body: Container(
        constraints: const BoxConstraints(
          maxWidth: ScreenLayout.maxFullscreenPageWidth + 180,
        ),
        child: SpecialEmojiKeyboardProvider(
          controller: bloc.specialEmojiController,
          builder: (final context) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(20),
                    Expanded(
                      child: ProjectTextField(
                        hintText: S.current.writeANote,
                        fillColor: Colors.transparent,
                        filled: false,
                        limit: note.charactersLimit,
                        focusNode: bloc.focusNode,
                        endlessLines: true,
                        focusOnInit: note.note.isEmpty,
                        onSubmit: bloc.onBack,
                        controller: bloc.noteController,
                        undoController: bloc.undoController,
                      ),
                    ),
                    const NoteProjectSideActionBar(),
                  ],
                ),
              ),
              if ((PlatformInfo.isNativeDesktop || kIsWeb) &&
                  !specialEmojiController.value.isKeyboardOpen)
                const Gap(16),
              if (!specialEmojiController.value.isKeyboardOpen)
                const BottomSafeArea(),
            ],
          ),
        ),
      ),
    );
  }
}
