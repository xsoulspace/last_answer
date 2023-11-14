import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_note/widgets/note_project_side_actionbar.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

part 'note_project_view_bloc.dart';

class NoteProjectViewDelegate {
  const NoteProjectViewDelegate({
    required this.noteId,
    required this.onBack,
    required this.onGoHome,
    required this.checkIsProjectActive,
  });
  final String noteId;
  final ValueChanged<ProjectModelNote> onBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;
}

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

class NoteProjectViewProvider extends StatelessWidget {
  const NoteProjectViewProvider({
    required this.builder,
    required this.delegate,
    super.key,
  });
  final WidgetBuilder builder;
  final NoteProjectViewDelegate delegate;

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (final context) => NoteProjectViewBloc(
              delegate: delegate,
              dto: NoteProjectViewStateDto(context: context),
            ),
          ),
        ],
        builder: (final context, final child) => builder(context),
      );
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
    final state = context.watch<NoteProjectViewBloc>();
    double? appBarHeight;
    if (Platform.isMacOS) {
      appBarHeight = null;
    } else {
      appBarHeight = screenLayout.small ? 40 : 30;
    }
    final note = state.value.value;

    return Scaffold(
      backgroundColor: theme.canvasColor,
      restorationId: 'notes/${delegate.noteId}',
      resizeToAvoidBottomInset: false,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        height: appBarHeight,
        screenLayout: screenLayout,
        titleStr: '',
        onBack: state.onBack,
      ),
      body: Builder(
        builder: (final context) {
          if (!state.value.isLoaded) {
            return const CircularProgressIndicator.adaptive();
          }

          return Container(
            constraints: const BoxConstraints(
              maxWidth: ScreenLayout.maxFullscreenPageWidth + 180,
            ),
            child: SpecialEmojisKeyboardActions(
              focusNode: state.focusNode,
              controller: state.noteController,
              builder: (
                final context,
                final showEmojiKeyboard,
                final closeEmojiKeyboard,
                final isEmojiKeyboardOpen,
              ) =>
                  Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: ProjectTextField(
                            hintText: S.current.writeANote,
                            fillColor: Colors.transparent,
                            filled: false,
                            limit: note.charactersLimit,
                            focusNode: state.focusNode,
                            endlessLines: true,
                            focusOnInit: note.note.isEmpty,
                            onSubmit: state.onBack,
                            controller: state.noteController,
                            undoController: state.undoController,
                          ),
                        ),
                        NoteProjectSideActionBar(
                          closeEmojiKeyboard: closeEmojiKeyboard,
                          isEmojiKeyboardOpen: isEmojiKeyboardOpen,
                          note: note,
                          noteController: state.noteController,
                          noteFocusNode: state.focusNode,
                          onRemove: state.onRemove,
                          showEmojiKeyboard: showEmojiKeyboard,
                          updatesStream: updatesStream,
                        ),
                      ],
                    ),
                  ),
                  if ((isNativeDesktop || kIsWeb) && !isEmojiKeyboardOpen.value)
                    const SizedBox(height: 16),
                  if (!isEmojiKeyboardOpen.value) const BottomSafeArea(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
