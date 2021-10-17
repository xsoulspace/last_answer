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
    final project = ref.read(ideaProjectsProvider).state[projectId]!;
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
              decoration: const InputDecoration()
                  .applyDefaults(Theme.of(context).inputDecorationTheme)
                  .copyWith(
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (answers.value.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: answers.value.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (final context, final index) {
                  final _answer = answers.value[index];
                  return _AnswerTile(
                    key: ValueKey(_answer.id),
                    answer: _answer,
                    confirmDelete: () => true,
                    onReadyToDelete: () {
                      answers.value.remove(_answer);
                      project
                        ..answers?.remove(_answer)
                        ..save();
                    },
                    deleteIconVisible: isDesktop,
                  );
                },
              ),
            ),
          // _AnswerCreator(
          //   onCreated: (final answer) async {
          //     answers.value.add(answer);
          //     project.answers?.add(answer);
          //     await project.save();
          //   },
          // ),
          const SafeAreaBottom(),
        ],
      ),
    );
  }
}
