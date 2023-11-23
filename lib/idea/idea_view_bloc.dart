import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator.dart';

part 'idea_view_bloc.freezed.dart';

class IdeaViewBlocDto {
  IdeaViewBlocDto({
    required this.initialIdea,
    required this.context,
  })  : openedProjectNotifier = context.read(),
        projectsNotifier = context.read();
  final ProjectModelIdea initialIdea;
  final BuildContext context;
  final ProjectsNotifier projectsNotifier;
  final OpenedProjectNotifier openedProjectNotifier;
}

@freezed
class IdeaViewBlocState with _$IdeaViewBlocState {
  const factory IdeaViewBlocState({
    required final ProjectModelIdea idea,
  }) = _IdeaViewBlocState;
}

class IdeaViewBloc extends ValueNotifier<IdeaViewBlocState> {
  IdeaViewBloc({required this.dto})
      : super(IdeaViewBlocState(idea: dto.initialIdea));
  late final AnswerCreatorController draftAnswerController =
      AnswerCreatorController(
    dto: AnswerCreatorControllerDto(
      ideaViewBloc: this,
      projectsNotifier: dto.projectsNotifier,
    ),
  );

  final IdeaViewBlocDto dto;
  late final titleController =
      TextEditingController(text: dto.initialIdea.title)
        ..addListener(_onChanged);
  ProjectModelIdea get idea => value.idea;
  void _onChanged() {
    final updatedIdea = value.idea.copyWith(
      title: titleController.text,
      updatedAt: DateTime.now(),
    );
    setValue(value.copyWith(idea: updatedIdea));
    dto.openedProjectNotifier.updateProject(updatedIdea);
  }

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: idea.title,
      context: context,
    );
    if (!remove) return;
    dto.openedProjectNotifier.deleteProject();
  }

  void onSubmit() {
    unawaited(SoftKeyboard.close());
  }

  void onExpandAnswer({
    required final IdeaProjectAnswerModel answer,
    required final int index,
  }) {
    // TODO(arenukvern): description,
  }

  void onAnswerChanged({
    required final IdeaProjectAnswerModel answer,
    required final int index,
  }) {
    final updatedAnswers = [...idea.answers]..[index] = answer;
    final updatedIdea = idea.copyWith(answers: updatedAnswers);
    setValue(value.copyWith(idea: updatedIdea));
    dto.openedProjectNotifier.updateProject(updatedIdea);
  }

  void onUpdateDraftAnswer({
    required final String text,
    required final IdeaProjectQuestionModel question,
  }) {
    final draftAnswer = dto.initialIdea.draftAnswer?.copyWith(
          question: question,
        ) ??
        IdeaProjectAnswerModel(
          id: IdeaProjectAnswerModelId(value: createId()),
          createdAt: DateTime.now(),
          question: question,
        );
    final updatedIdea = idea.copyWith(
      draftAnswer: draftAnswer.copyWith(text: text),
    );
    setValue(value.copyWith(idea: updatedIdea));
    dto.openedProjectNotifier.updateProject(updatedIdea);
  }

  void onCreateAnswerFromDraft() {
    final newAnswer = idea.draftAnswer;
    if (newAnswer == null) {
      assert(true, 'No draft answer');
      return;
    }
    final updatedAnswers = [newAnswer, ...idea.answers];
    final updatedIdea = idea.copyWith(answers: updatedAnswers);
    setValue(value.copyWith(idea: updatedIdea));
    dto.openedProjectNotifier.updateProject(updatedIdea);
  }

  @override
  void dispose() {
    draftAnswerController.dispose();
    titleController
      ..removeListener(_onChanged)
      ..dispose();

    super.dispose();
  }
}
