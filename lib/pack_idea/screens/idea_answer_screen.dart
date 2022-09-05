import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_idea/screens/idea_answer_screen_state.dart';
import 'package:lastanswer/pack_idea/widgets/question_dropdown.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class IdeaAnswerScreen extends HookWidget {
  const IdeaAnswerScreen({
    required this.ideaId,
    required this.answerId,
    required this.onBack,
    required this.onUnknown,
    final Key? key,
  }) : super(key: key);
  final String ideaId;
  final String answerId;
  final ValueChanged<IdeaProject> onBack;

  /// callback to redirect if answerId is not found
  final TwoValuesChanged<IdeaProjectAnswerId, IdeaProject> onUnknown;

  IdeaProjectAnswer? getInitialAnswer({
    required final IdeaProject idea,
    required final IdeaProjectAnswersNotifier ideaAnswersNotifier,
  }) {
    final answer = ideaAnswersNotifier.state[answerId];
    if (answer != null) return answer;
    onUnknown(answerId, idea);

    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final ideasNotifier = context.watch<IdeaProjectsNotifier>();
    final ideaAnswersNotifier = context.watch<IdeaProjectAnswersNotifier>();
    final maybeIdea = ideasNotifier.state[ideaId]!;
    final maybeAnswer = getInitialAnswer(
      idea: maybeIdea,
      ideaAnswersNotifier: ideaAnswersNotifier,
    );
    if (maybeAnswer == null) return Container();
    final answer = useState<IdeaProjectAnswer>(maybeAnswer);
    final textController = useTextEditingController(text: answer.value.text);
    // ignore: close_sinks
    final updatesStream = useStreamController<bool>();

    final state = useIdeaAnswerScreenState(
      ideasNotifier: ideasNotifier,
      answerNotifier: answer,
      idea: maybeIdea,
      onScreenBack: onBack,
      textController: textController,
      updatesStream: updatesStream,
      ideaAnswerSyncService: context.watch(),
      ideaSyncService: context.watch(),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      restorationId: 'ideas/$ideaId/$answerId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroId(
            id: '$answerId-question${maybeAnswer.question.id}',
            type: HeroIdTypes.projectIdeaQuestionTitle,
            child: QuestionDropdown(
              answer: answer.value,
              alignment: Alignment.center,
            ),
          ),
        ),
        onBack: state.onBack,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ScreenLayout.minFullscreenPageWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: HeroId(
                    id: answerId,
                    type: HeroIdTypes.projectIdeaAnswerText,
                    child: FlatTextField(
                      hintText: S.current.answer,
                      fillColor: Colors.transparent,
                      filled: false,
                      endlessLines: true,
                      focusOnInit: textController.text.isEmpty,
                      onSubmit: state.onBack,
                      controller: textController,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const BottomSafeArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
