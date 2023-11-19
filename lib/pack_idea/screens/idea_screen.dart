import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_app/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator.dart';
import 'package:lastanswer/pack_idea/widgets/answer_tile.dart';
import 'package:life_hooks/life_hooks.dart';

typedef TwoValuesChanged<TFirst, TSecond> = void Function(TFirst, TSecond);

class IdeaProjectScreen extends HookWidget {
  const IdeaProjectScreen({
    required this.onBack,
    required this.ideaId,
    required this.onAnswerExpand,
    super.key,
  });
  final VoidCallback onBack;
  final TwoValuesChanged<IdeaProjectAnswer, IdeaProject> onAnswerExpand;
  final ProjectId ideaId;

  @override
  Widget build(final BuildContext context) {
    // ignore: close_sinks
    final ideaUpdatesStream = useStreamController<bool>();
    final ideasProvider = context.read<IdeaProjectsState>();
    final ideaQuestionsProvider = context.read<IdeaProjectQuestionsState>();
    final idea = ideasProvider.state.value[ideaId];
    final titleController = useTextEditingController(text: idea.title);
    final answers =
        useState<List<IdeaProjectAnswer>>([...?idea.answers?.reversed]);
    final scrollController = useScrollController();
    final questions = ideaQuestionsProvider.state;
    final questionsOpened = useIsBool();

    final state = useIdeaScreenState(
      context: context,
      onScreenBack: onBack,
      answers: answers,
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
        onBack: onBack,
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
                itemCount: answers.value.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (final context, final index) {
                  if (index > answers.value.length - 1 || index < 0) {
                    return Container();
                  }
                  final answer = answers.value[index];

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
                      onAnswerExpand(answer, idea);
                    },
                    onReadyToDelete: state.onReadyToDeleteAnswer,
                    onChange: state.onAnswersChange,
                    deleteIconVisible: PlatformInfo.isNativeWebDesktop,
                  );
                },
              ),
            ),
          ),
          AnswerCreator(
            onShareTap: () async {
              await ProjectSharer.of(context).share(sharable: idea);
            },
            questionsOpened: questionsOpened,
            onFocus: state.openQuestions,
            idea: idea,
            defaultQuestion: answers.value.isNotEmpty
                ? answers.value.first.question
                : questions.value.values.first,
            onChanged: state.onAnswersChange,
            onCreated: state.onAnswerCreated,
          ),
          const BottomSafeArea(),
        ],
      ),
    );
  }
}
