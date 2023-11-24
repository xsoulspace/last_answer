import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view_bloc.dart';
import 'package:lastanswer/pack_app/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/widgets/questions_chips.dart';

part 'answer_creator.freezed.dart';

@freezed
class AnswerCreatorControllerState with _$AnswerCreatorControllerState {
  const factory AnswerCreatorControllerState({
    required final IdeaProjectQuestionModel question,
    @Default(false) final bool isQuestionsOpened,
  }) = _AnswerCreatorControllerState;
}

class AnswerCreatorControllerDto {
  AnswerCreatorControllerDto({
    required this.ideaViewBloc,
    required this.projectsNotifier,
  });
  final IdeaViewBloc ideaViewBloc;
  final ProjectsNotifier projectsNotifier;

  IdeaProjectQuestionModel get initialQuestion {
    IdeaProjectQuestionModel? question =
        ideaViewBloc.idea.draftAnswer?.question;
    if (question != null) return question;

    final answers = ideaViewBloc.idea.answers;
    question = answers.firstOrNull?.question;
    if (question != null) return question;

    return projectsNotifier.ideaQuestions.first;
  }

  String get initialText => ideaViewBloc.idea.draftAnswer?.text ?? '';
}

class AnswerCreatorController
    extends ValueNotifier<AnswerCreatorControllerState> {
  AnswerCreatorController({
    required this.dto,
  }) : super(
          AnswerCreatorControllerState(question: dto.initialQuestion),
        );
  late final _textUpdatesController = StreamController<String>()
    ..stream
        .sampleTime(
          const Duration(milliseconds: 200),
        )
        .forEach(_save);
  void _addTextUpdate() => _textUpdatesController.add(answerController.text);
  late final answerController = TextEditingController(text: dto.initialText)
    ..addListener(_addTextUpdate);
  final FocusNode focusNode = FocusNode();
  final AnswerCreatorControllerDto dto;
  Future<void> onShare(final BuildContext context) async {
    await ProjectSharer.of(context).share(sharable: dto.ideaViewBloc.idea);
  }

  void changeQuestion(final IdeaProjectQuestionModel newQuestion) {
    final updatedState = value.copyWith(question: newQuestion);
    setValue(updatedState);
    _save();
  }

  void onCreateAnswer() {
    final text = answerController.text;
    if (text.isEmpty) return;
    _save();
    answerController.clear();
    dto.ideaViewBloc.onCreateAnswerFromDraft();
  }

  @override
  void dispose() {
    focusNode.dispose();
    answerController.dispose();
    unawaited(_textUpdatesController.close());
    super.dispose();
  }

  void updateIsQuestionsOpened({required final bool isOpened}) {
    final updatedState = value.copyWith(isQuestionsOpened: isOpened);
    setValue(updatedState);
  }

  void onFocus() => updateIsQuestionsOpened(isOpened: true);
  void onUnfocus() {}

  void _save([final String? text]) => dto.ideaViewBloc.onUpdateDraftAnswer(
        text: answerController.text,
        question: value.question,
      );
}

class AnswerCreator extends HookWidget {
  const AnswerCreator({
    required this.controller,
    super.key,
  });
  final AnswerCreatorController controller;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    useListenable(controller);

    final controllerState = controller.value;
    final isQuestionsOpened = controllerState.isQuestionsOpened;
    final selectedQuestion = controllerState.question;

    final sendButton = RotatedBox(
      quarterTurns: 3,
      child: IconButton(
        onPressed: controller.answerController.text.isNotEmpty
            ? controller.onCreateAnswer
            : null,
        color: theme.colorScheme.primary,
        icon: const Icon(Icons.send),
      ),
    );
    final shareButton = Hero(
      tag: const Key('shareButton'),
      child: IconShareButton(
        onTap: () async => controller.onShare(context),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.theme.colorScheme.onSecondary,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isQuestionsOpened)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 2,
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: QuestionsChips(
                      onChange: controller.changeQuestion,
                      value: selectedQuestion,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        shareButton,
                        EmojiPopup(
                          controller: controller.answerController,
                          focusNode: controller.focusNode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: ProjectTextField(
                    hintText: context.l10n.writeAnAnswer,
                    focusOnInit:
                        controller.dto.ideaViewBloc.idea.answers.isEmpty,
                    controller: controller.answerController,
                    onSubmit: controller.onCreateAnswer,
                    focusNode: controller.focusNode,
                    onFocus: controller.onFocus,
                    onUnfocus: controller.onUnfocus,
                  ),
                ),
                if (isQuestionsOpened) sendButton else shareButton,
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
