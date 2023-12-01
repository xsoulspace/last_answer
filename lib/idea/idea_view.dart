import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/idea_view_bloc.dart';
import 'package:lastanswer/idea/widgets/answer_creator.dart';
import 'package:lastanswer/idea/widgets/answer_tile.dart';
import 'package:lastanswer/pack_app/widgets/project_title_field.dart';

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
    final answers = bloc.value.idea.answers;
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
          onBack: () => context.go(ScreenPaths.home),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    closeKeyboard(context: context);
                    // state.closeQuestions();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: AnimatedList(
                    key: bloc.listKey,
                    padding: const EdgeInsets.only(
                      bottom: 32,
                      left: 8,
                      right: 12,
                    ),
                    initialItemCount: answers.length,
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (final context, final index, final animation) {
                      final answer = answers[index];

                      return AnswerTile(
                        key: ValueKey(answer.id.value),
                        onFocus: () => bloc.draftAnswerController
                            .updateIsQuestionsOpened(isOpened: false),
                        answer: answer,
                        confirmDelete: () async => showRemoveTitleDialog(
                          title: answer.title,
                          context: context,
                        ),
                        onExpand: (final _) {
                          closeKeyboard(context: context);
                          unawaited(
                            bloc.onExpandAnswer(
                              answer: answer,
                              index: index,
                              context: context,
                            ),
                          );
                        },
                        onReadyToDelete: (final answer) {
                          bloc.onDeleteAnswer(answer: answer, index: index);
                        },
                        onChanged: (final answer) =>
                            bloc.onAnswerChanged(answer: answer, index: index),
                        deleteIconVisible: PlatformInfo.isNativeWebDesktop,
                      );
                    },
                  ),
                ),
              ),
              AnswerCreator(controller: bloc.draftAnswerController),
              const BottomSafeArea(),
            ],
          ),
        ),
      ],
    );
  }
}
