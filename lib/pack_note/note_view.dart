import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/widgets/note_project_side_actionbar.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit_state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

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
    required this.delegate,
    super.key,
  });
  final NoteProjectViewDelegate delegate;

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
      restorationId: 'notes/${delegate.noteId}',
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
              if ((isNativeDesktop || kIsWeb) &&
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