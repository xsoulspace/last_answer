part of idea_project;

typedef TwoValuesChanged<TFirst, TSecond> = void Function(TFirst, TSecond);

class IdeaProjectScreen extends HookConsumerWidget {
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
  Widget build(final BuildContext context, final WidgetRef ref) {
    final idea = ref.read(ideaProjectsProvider)[ideaId]!;
    final titleController = useTextEditingController(text: idea.title);
    final answers =
        useState<List<IdeaProjectAnswer>>([...idea.answers?.reversed ?? []]);
    final scrollController = useScrollController();
    final questions = ref.read(ideaProjectQuestionsProvider);
    final questionsOpened = useIsBool();

    void closeQuestions() {
      if (questionsOpened.value) questionsOpened.value = false;
    }

    void openQuestions() {
      if (!questionsOpened.value) questionsOpened.value = true;
    }

    return Scaffold(
      restorationId: 'ideas/scaffold/$ideaId',
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
        toolbarHeight: 55,
        title: _IdeaScreenTitle(
          onFocus: closeQuestions,
          controller: titleController,
          idea: idea,
          onChanged: (final text) {
            idea
              ..title = text
              ..save();
          },
        ),
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
                padding: const EdgeInsets.all(10),
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
                    confirmDelete: () => true,
                    onExpand: (final _) {
                      closeKeyboard(context: context);
                      onAnswerExpand(_answer, idea);
                    },
                    onReadyToDelete: () async {
                      idea.answers?.remove(_answer);
                      await idea.save();
                      answers.value = [...idea.answers?.reversed ?? []];
                    },
                    deleteIconVisible: isDesktop,
                  );
                },
              ),
            ),
          ),
          _AnswerCreator(
            onShareTap: () {},
            questionsOpened: questionsOpened,
            onFocus: openQuestions,
            idea: idea,
            defaultQuestion: answers.value.isNotEmpty
                ? answers.value[0].question
                : questions.values.first,
            onCreated: (final answer) async {
              idea.answers?.add(answer);
              await idea.save();
              answers.value = [...idea.answers?.reversed ?? []];
            },
          ),
          const SafeAreaBottom(),
        ],
      ),
    );
  }
}
