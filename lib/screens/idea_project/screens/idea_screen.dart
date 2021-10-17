part of idea_project;

class IdeaProjectScreen extends HookConsumerWidget {
  const IdeaProjectScreen({
    required final this.onBack,
    required final this.ideaId,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ProjectId ideaId;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final idea = ref.read(ideaProjectsProvider)[ideaId]!;
    final titleController = useTextEditingController(text: idea.title);
    final answers = useState<List<IdeaProjectAnswer>>(idea.answers ?? []);
    return Scaffold(
      restorationId: 'ideas/$ideaId',
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
        toolbarHeight: 70,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroProjectTitle(
            project: idea,
            child: TextField(
              controller: titleController,
              onChanged: (final text) {
                idea
                  ..title = text
                  ..save();
              },
              style: Theme.of(context).textTheme.bodyText2,
              decoration: const InputDecoration()
                  .applyDefaults(Theme.of(context).inputDecorationTheme)
                  .copyWith(
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: defaultBorderRadius,
                    ),
                  ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.separated(
                restorationId: 'ideas/$ideaId/answers',
                separatorBuilder: (final _, final __) =>
                    const SizedBox(height: 26),
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: answers.value.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (final context, final index) {
                  final _answer = answers.value[index];
                  return _AnswerTile(
                    key: ValueKey(_answer.id),
                    answer: _answer,
                    confirmDelete: () => true,
                    onReadyToDelete: () {
                      answers.value.remove(_answer);
                      answers.value = answers.value;
                      idea
                        ..answers?.remove(_answer)
                        ..save();
                    },
                    deleteIconVisible: isDesktop,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            _AnswerCreator(
              onShareTap: () {},
              idea: idea,
              defaultQuestion:
                  answers.value.isNotEmpty ? answers.value[0].question : null,
              onCreated: (final answer) async {
                idea.answers?.add(answer);
                answers.value = idea.answers ?? [];
                await idea.save();
              },
            ),
            const SafeAreaBottom(),
          ],
        ),
      ),
    );
  }
}
