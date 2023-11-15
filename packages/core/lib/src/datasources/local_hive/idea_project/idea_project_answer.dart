part of '../hive_models.dart';

typedef IdeaProjectAnswerId = String;

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends HiveObject
    with EquatableMixin
    implements Sharable, HasId {
  IdeaProjectAnswer({
    required this.text,
    required this.question,
    required this.id,
    required this.created,
  });
  static Future<IdeaProjectAnswer> create({
    required final String text,
    required final IdeaProjectQuestion question,
  }) async {
    final answer = IdeaProjectAnswer(
      text: text,
      question: question,
      id: createId(),
      created: DateTime.now(),
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
  final DateTime created;

  String get title => text.length <= 50 ? text : text.substring(0, 49);
  @override
  String toShareString() => '${question.toShareString()} \n $text';

  @override
  List get props => [id];

  @override
  bool? get stringify => true;

  IdeaProjectAnswerModel toModel() => IdeaProjectAnswerModel(
        createdAt: created,
        id: IdeaProjectAnswerModelId.fromJson(id),
        question: question.toModel(),
        text: text,
      );

  @override
  String get sharableTitle => '';
}

/// A mock for [IdeaProjectAnswer].
/// To create use `final mockIdeaProjectAnswer = MockIdeaProjectAnswer();`
// ignore: avoid_implementing_value_types
class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}