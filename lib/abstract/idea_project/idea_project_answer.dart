part of abstract;

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends HiveObject
    with EquatableMixin
    implements Sharable, DeletableWithId {
  IdeaProjectAnswer({
    required this.id,
    required this.text,
    required this.question,
    required this.createdAt,
    this.isToDelete = false,
    final DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
  static Future<IdeaProjectAnswer> create({
    required final String text,
    required final IdeaProjectQuestion question,
  }) async {
    final answer = IdeaProjectAnswer(
      text: text,
      question: question,
      id: createId(),
      createdAt: DateTime.now(),
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
  final DateTime updatedAt;

  @override
  @HiveField(5)
  bool isToDelete;

  String get title => text.length <= 50 ? text : text.substring(0, 49);
  @override
  String toShareString() => '${question.toShareString()} \n $text';

  @override
  List get props => [id];

  @override
  bool? get stringify => true;
}

/// A mock for [IdeaProjectAnswer].
/// To create use `final mockIdeaProjectAnswer = MockIdeaProjectAnswer();`
// ignore: avoid_implementing_value_types
// class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}
