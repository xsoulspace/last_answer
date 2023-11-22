import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view_bloc.dart';
import 'package:lastanswer/pack_app/widgets/project_title_field.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator.dart';
import 'package:lastanswer/pack_idea/widgets/answer_tile.dart';

class IdeaView extends StatelessWidget {
  const IdeaView({
    required this.idea,
    super.key,
  });
  final ProjectModelIdea idea;

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final _) => IdeaViewBloc(
          dto: IdeaViewBlocDto(
            initialIdea: idea,
            context: context,
          ),
        ),
        builder: (final context, final child) => const IdeaViewBody(),
      );
}

class IdeaViewBody extends StatelessWidget {
  const IdeaViewBody({super.key});
  @override
  Widget build(final BuildContext context) {
    final bloc = context.watch<IdeaViewBloc>();
    final answers = bloc.value.answers;
    final questions = context.watch<ProjectsNotifier>();
    return Column(
      children: [
        BackTextUniversalAppBar(
          useBackButton: true,
          screenLayout: ScreenLayout.of(context),
          title: ProjectTitleField(
            // onFocus: state.closeQuestions,
            controller: bloc.titleController,
            heroId: bloc.dto.initialIdea.id.value,
            onChanged: (final _) {},
          ),
          onBack: context.pop,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  closeKeyboard(context: context);
                  // state.closeQuestions();
                },
                behavior: HitTestBehavior.translucent,
                child: ListView.separated(
                  // key: PageStorageKey('ideas/listeview/$ideaId/answers'),
                  // controller: scrollController,
                  // restorationId: 'ideas/listeview/$ideaId/answers',
                  separatorBuilder: (final _, final __) =>
                      const SizedBox(height: 26),
                  padding:
                      const EdgeInsets.all(10).copyWith(bottom: 24, top: 0),
                  itemCount: answers.length,
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (final context, final index) {
                    if (index > answers.length - 1 || index < 0) {
                      return Container();
                    }
                    final answer = answers[index];

                    return AnswerTile(
                      onFocus: () {}, //state.closeQuestions,
                      key: ValueKey(answer),
                      answer: answer,
                      confirmDelete: () async => showRemoveTitleDialog(
                        title: answer.title,
                        context: context,
                      ),
                      onExpand: (final _) {
                        closeKeyboard(context: context);
                        // onAnswerExpand(answer, idea);
                      },
                      onReadyToDelete:
                          (final _) {}, // state.onReadyToDeleteAnswer,
                      onChange: () {}, //state.onAnswersChange,
                      deleteIconVisible: PlatformInfo.isNativeWebDesktop,
                    );
                  },
                ),
              ),
            ),
            AnswerCreator(
              onShareTap: () async {
                await ProjectSharer.of(context).share(sharable: bloc.idea);
              },
              questionsOpened: questionsOpened,
              onFocus: () {}, //state.openQuestions,
              idea: bloc.idea,
              defaultQuestion: answers.isNotEmpty
                  ? answers.firstOrNull?.question
                  : questions.value.values.first,
              onChanged: () {}, //state.onAnswersChange,
              onCreated: (final _) {}, //state.onAnswerCreated,
            ),
            const BottomSafeArea(),
          ],
        ),
      ],
    );
  }
}
