part of pack_idea;

typedef TwoValuesChanged<TFirst, TSecond> = void Function(TFirst, TSecond);

class IdeaProjectScreen extends HookWidget {
  const IdeaProjectScreen({
    required final this.onBack,
    required final this.ideaId,
    required final this.onAnswerExpand,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final TwoValuesChanged<IdeaProjectAnswer, IdeaProject> onAnswerExpand;
  final ProjectId ideaId;

  @override
  Widget build(final BuildContext context) {
    // ignore: close_sinks
    final ideaUpdatesStream = useStreamController<bool>();
    final ideasProvider = context.read<IdeaProjectsProvider>();
    final ideaQuestionsProvider = context.read<IdeaProjectQuestionsProvider>();
    final idea = ideasProvider.state[ideaId]!;
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

                  return _AnswerTile(
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
                    deleteIconVisible: isDesktop,
                  );
                },
              ),
            ),
          ),
          _AnswerCreator(
            onShareTap: () async {
              await ProjectSharer.of(context).share(project: idea);
            },
            questionsOpened: questionsOpened,
            onFocus: state.openQuestions,
            idea: idea,
            defaultQuestion: answers.value.isNotEmpty
                ? answers.value.first.question
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
