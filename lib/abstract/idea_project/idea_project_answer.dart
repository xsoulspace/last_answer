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

  @HiveField(projectLatestFieldHiveId + 1)
  String text;

  @HiveField(projectLatestFieldHiveId + 2)
  IdeaProjectQuestion question;

  @HiveField(projectLatestFieldHiveId + 3)
  final String id;

  @HiveField(projectLatestFieldHiveId + 4)
  final DateTime created;

  @HiveField(projectLatestFieldHiveId + 5)
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
