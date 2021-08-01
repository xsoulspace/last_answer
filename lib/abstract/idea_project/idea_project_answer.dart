part of abstract;

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends HiveObject with EquatableMixin {
  IdeaProjectAnswer({
    required final this.text,
    required final this.question,
    required final this.index,
  })  : id = createId(),
        created = DateTime.now();

  @HiveField(0)
  String text;

  @HiveField(1)
  IdeaProjectQuestion question;

  @HiveField(3)
  final String id;

  @HiveField(4)
  final DateTime created;

  @HiveField(5)
  int index;

  @override
  List get props => [id];

  @override
  bool? get stringify => true;
}

/// A mock for [IdeaProjectAnswer].
/// To create use `final mockIdeaProjectAnswer = MockIdeaProjectAnswer();`
// ignore: avoid_implementing_value_types
class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}
