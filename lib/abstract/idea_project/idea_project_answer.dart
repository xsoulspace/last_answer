part of abstract;

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends HiveObjectWithId
    with EquatableMixin
    implements Sharable, RemotelyAvailable<IdeaProjectAnswerModel> {
  IdeaProjectAnswer({
    required this.id,
    required this.text,
    required this.question,
    required this.createdAt,
    required this.projectId,
    this.isToDelete = false,
    final DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
  static Future<IdeaProjectAnswer> fromModel({
    required final IdeaProjectAnswerModel model,
    required final BuildContext context,
  }) async {
    final questions = context.read<IdeaProjectQuestionsNotifier>();
    final question = questions.state[model.questionId]!;

    return create(
      ideaId: model.projectId,
      question: question,
      text: model.text,
      createdAt: model.createdAt,
      id: model.id,
      updatedAt: model.updatedAt,
    );
  }

  static Future<IdeaProjectAnswer> create({
    required final String text,
    required final IdeaProjectQuestion question,
    required final ProjectId ideaId,
    final String? id,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) async {
    final answer = IdeaProjectAnswer(
      text: text,
      question: question,
      id: id ?? createId(),
      createdAt: createdAt ?? DateTime.now(),
      projectId: ideaId,
      updatedAt: updatedAt,
    );
    final box = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );
    await box.put(answer.id, answer);

    return answer;
  }

  @HiveField(0)
  String text;

  @HiveField(1)
  IdeaProjectQuestion question;

  @override
  @HiveField(2)
  final IdeaProjectAnswerId id;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @override
  @HiveField(5)
  bool isToDelete;

  @HiveField(6)
  final ProjectId projectId;

  String get title => text.length <= 50 ? text : text.substring(0, 49);
  @override
  String toShareString() => '${question.toShareString()} \n $text';

  @override
  List get props => [id];

  @override
  bool? get stringify => true;

  @override
  IdeaProjectAnswerModel toModel({required final UserModel user}) {
    return IdeaProjectAnswerModel(
      createdAt: createdAt,
      id: id,
      projectId: projectId,
      questionId: question.id,
      text: text,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    await delete();
  }
}

/// A mock for [IdeaProjectAnswer].
/// To create use `final mockIdeaProjectAnswer = MockIdeaProjectAnswer();`
// ignore: avoid_implementing_value_types
// class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}
