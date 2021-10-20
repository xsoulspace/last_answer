part of abstract;

typedef IdeaProjectAnswerId = String;

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends HiveObject
    with EquatableMixin
    implements Sharable {
  IdeaProjectAnswer({
    required final this.text,
    required final this.question,
    required final this.id,
    required final this.created,
  });
  static Future<IdeaProjectAnswer> create({
    required final String text,
    required final IdeaProjectQuestion question,
  }) async =>
      IdeaProjectAnswer(
        text: text,
        question: question,
        id: createId(),
        created: DateTime.now(),
      );

  @HiveField(0)
  String text;

  @HiveField(1)
  IdeaProjectQuestion question;

  @HiveField(2)
  final IdeaProjectAnswerId id;

  @HiveField(3)
  final DateTime created;

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
class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}
