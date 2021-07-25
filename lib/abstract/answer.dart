part of abstract;

@Deprecated('use IdeaProjectAnswer')
@HiveType(typeId: HiveBoxesIds.answers)
class Answer extends HiveObject with EquatableMixin {
  @Deprecated('use IdeaProjectAnswer')
  Answer({
    required final this.title,
    required final this.questionId,
    required final this.id,
    required final this.created,
    required final this.positionIndex,
  });
  @HiveField(0)
  String title;

  @HiveField(1)
  String questionId;

  @HiveField(3)
  final String id;
  @HiveField(4)
  final DateTime created;
  @HiveField(5)
  int? positionIndex;

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
