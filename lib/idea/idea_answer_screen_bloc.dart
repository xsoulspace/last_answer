import 'package:lastanswer/common_imports.dart';

class IdeaAnswerScreenStateDto {
  IdeaAnswerScreenStateDto({
    required this.context,
    required this.answer,
    required this.idea,
    required this.index,
  }) : projectsNotifier = context.read();
  final BuildContext context;
  final IdeaProjectAnswerModel answer;
  final int index;
  final ProjectModelIdea idea;
  final ProjectsNotifier projectsNotifier;
}

class IdeaAnswerScreenBloc extends ValueNotifier<IdeaProjectAnswerModel> {
  IdeaAnswerScreenBloc({
    required this.dto,
  }) : super(dto.answer) {
    unawaited(
      _updatesStream.stream
          .sampleTime(const Duration(milliseconds: 450))
          .forEach(_onSave),
    );
  }
  final IdeaAnswerScreenStateDto dto;
  final _updatesStream = StreamController<IdeaProjectAnswerModel>();

  Future<void> onQuestionUpdate(
    final IdeaProjectQuestionModel question,
  ) async =>
      setValue(value.copyWith(question: question));

  Future<void> onTextUpdate(final String text) async {
    setValue(value.copyWith(text: text));
  }

  Future<void> _onSave(final IdeaProjectAnswerModel answer) async {
    if (value == answer) return;
    final idea = dto.idea.copyWith(
      answers: [...dto.idea.answers]..[dto.index] = answer,
    );
    dto.projectsNotifier.updateProject(idea);
  }

  void onBack(final BuildContext context) {
    final navigator = Navigator.of(context);
    closeKeyboard(context: dto.context);
    navigator.pop(value);
  }

  @override
  void dispose() {
    unawaited(_updatesStream.close());
    super.dispose();
  }

  void setValue(final IdeaProjectAnswerModel answer) {
    value = answer;
    _updatesStream.add(answer);
  }
}
