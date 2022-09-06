import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_idea/screens/idea_screen_state.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator.dart';
import 'package:lastanswer/pack_idea/widgets/answer_tile.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

class IdeaProjectScreen extends HookWidget {
  const IdeaProjectScreen({
    required this.ideaId,
    final Key? key,
  }) : super(key: key);
  final ProjectId ideaId;

  @override
  Widget build(final BuildContext context) {
    // ignore: close_sinks
    final ideaUpdatesStream = useStreamController<bool>();
    final ideasNotifier = context.watch<IdeaProjectsNotifier>();
    final ideaQuestionsProvider = context.watch<IdeaProjectQuestionsNotifier>();
    final idea = ideasNotifier.state[ideaId];
    if (idea == null) return const SizedBox();

    final titleController = useTextEditingController(text: idea.title);
    final answers = idea.getAnswers(context);
    final answersNotifier = useState<List<IdeaProjectAnswer>>([...answers]);
    final scrollController = useScrollController();
    final questions = ideaQuestionsProvider.state;
    final questionsOpened = useIsBool();

    final state = useIdeaScreenState(
      ideaAnswerSyncService: context.watch(),
      ideaSyncService: context.watch(),
      folderNotifier: context.watch(),
      ideasNotifier: ideasNotifier,
      answersNotifier: answersNotifier,
      ideaUpdatesStream: ideaUpdatesStream,
      idea: idea,
      questionsOpened: questionsOpened,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      restorationId: 'ideas/scaffold/$ideaId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        screenLayout: ScreenLayout.of(context),
        title: ProjectTitleField(
          onFocus: state.closeQuestions,
          controller: titleController,
          heroId: idea.id,
          onChanged: state.onIdeaTitleChange,
        ),
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                closeKeyboard(context: context);
                state.closeQuestions();
              },
              behavior: HitTestBehavior.translucent,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                key: PageStorageKey('ideas/listeview/$ideaId/answers'),
                controller: scrollController,
                restorationId: 'ideas/listeview/$ideaId/answers',
                separatorBuilder: (final _, final __) =>
                    const SizedBox(height: 26),
                padding: const EdgeInsets.all(10).copyWith(bottom: 24, top: 0),
                itemCount: answersNotifier.value.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (final context, final index) {
                  if (index > answersNotifier.value.length - 1 || index < 0) {
                    return Container();
                  }
                  final answer = answersNotifier.value[index];

                  return AnswerTile(
                    onFocus: state.closeQuestions,
                    key: ValueKey(answer),
                    answer: answer,
                    confirmDelete: () async => showRemoveTitleDialog(
                      title: answer.title,
                      context: context,
                    ),
                    onExpand: (final _) {
                      closeKeyboard(context: context);
                      context
                          .read<AppRouterController>()
                          .onExpandIdeaAnswer(answer, idea);
                    },
                    onReadyToDelete: state.onReadyToDeleteAnswer,
                    onChange: state.onAnswersChange,
                    deleteIconVisible: DeviceRuntimeType.isDesktop,
                  );
                },
              ),
            ),
          ),
          AnswerCreator(
            answersIsEmpty: answers.isEmpty,
            onShareTap: () async {
              await ProjectSharer.of(context).share(project: idea);
            },
            questionsOpened: questionsOpened,
            onFocus: state.openQuestions,
            idea: idea,
            defaultQuestion: answersNotifier.value.isNotEmpty
                ? answersNotifier.value.first.question
                : questions.values.first,
            onChanged: state.onAnswersChange,
            onCreated: state.onAnswerCreated,
          ),
          const BottomSafeArea(),
        ],
      ),
    );
  }
}
