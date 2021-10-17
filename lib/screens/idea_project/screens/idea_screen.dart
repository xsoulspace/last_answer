part of idea_project;

class IdeaProjectScreen extends HookConsumerWidget {
  const IdeaProjectScreen({
    required final this.onBack,
    required final this.projectId,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ProjectId projectId;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final project = ref.read(ideaProjectsProvider)[projectId]!;
    final titleController = useTextEditingController(text: project.title);
    final answers = useState<List<IdeaProjectAnswer>>(project.answers ?? []);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: onBack,
        ),
        toolbarHeight: 70,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroProjectTitle(
            project: project,
            child: TextField(
              controller: titleController,
              onChanged: (final text) {
                project
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
                      project
                        ..answers?.remove(_answer)
                        ..save();
                    },
                    deleteIconVisible: isDesktop,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _AnswerCreator(
              onCreated: (final answer) async {
                project.answers?.add(answer);
                answers.value = project.answers ?? [];
                await project.save();
              },
            ),
            const SafeAreaBottom(),
          ],
        ),
      ),
    );
  }
}
