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

    final idea = ideaProjectsProvider.state.state[ideaId]!;
    final titleController = useTextEditingController(text: idea.title);
    final answers =
        useState<List<IdeaProjectAnswer>>([...idea.answers?.reversed ?? []]);
    final scrollController = useScrollController();
    final questions = ideaProjectQuestionsProvider.state;
    final questionsOpened = useIsBool();

    ideaUpdatesStream.stream
        .throttleTime(
      const Duration(milliseconds: 700),
      leading: true,
      trailing: true,
    )
        .forEach((final _) async {
      ideaProjectsProvider
        ..state.put(key: idea.id, value: idea)
        ..notify();
      return idea.save();
    });

    void closeQuestions() {
      if (questionsOpened.value) questionsOpened.value = false;
    }

    void openQuestions() {
      if (!questionsOpened.value) questionsOpened.value = true;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      restorationId: 'ideas/scaffold/$ideaId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        screenLayout: ScreenLayout.of(context),
        title: ProjectTitleField(
          onFocus: closeQuestions,
          controller: titleController,
          heroId: idea.id,
          onChanged: (final text) {
            if (text == idea.title) return;
            idea.title = text;
            ideaUpdatesStream.add(true);
          },
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
                closeQuestions();
              },
              behavior: HitTestBehavior.translucent,
              child: ListView.separated(
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
                  final _answer = answers.value[index];
                  return _AnswerTile(
                    onFocus: closeQuestions,
                    key: ValueKey(_answer.id),
                    answer: _answer,
                    confirmDelete: () async => showRemoveTitleDialog(
                      title: _answer.title,
                      context: context,
                    ),
                    onExpand: (final _) {
                      closeKeyboard(context: context);
                      onAnswerExpand(_answer, idea);
                    },
                    onReadyToDelete: () async {
                      idea.answers?.remove(_answer);
                      answers.value = [...idea.answers?.reversed ?? []];
                      ideaUpdatesStream.add(true);
                    },
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
            onFocus: openQuestions,
            idea: idea,
            defaultQuestion: answers.value.isNotEmpty
                ? answers.value[0].question
                : questions.values.first,
            onCreated: (final answer) async {
              idea.answers?.add(answer);
              answers.value = [...idea.answers?.reversed ?? []];
              ideaUpdatesStream.add(true);
            },
          ),
          const BottomSafeArea(),
        ],
      ),
    );
  }
}
