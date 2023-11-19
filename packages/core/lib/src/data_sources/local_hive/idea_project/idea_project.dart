// ignore_for_file: overridden_fields
part of '../hive_models.dart';

typedef IdeaProjectId = String;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject with EquatableMixin {
  IdeaProject({
    required super.id,
    required super.title,
    required super.created,
    required super.updated,
    this.folder,
    super.isCompleted,
    this.newAnswerText = '',
    this.newQuestion,
    this.answers,
  }) : super(
          folder: folder,
          type: ProjectTypes.idea,
        );
  static Future<IdeaProject> create({
    required final String title,
    required final ProjectFolder folder,
  }) async {
    final created = DateTime.now();
    final idea = IdeaProject(
      updated: created,
      created: created,
      folder: folder,
      id: createId(),
      title: title,
    );
    final ideaBox =
        await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
    final ideaAnswersBox = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );
    await ideaBox.put(idea.id, idea);
    idea.answers = HiveList<IdeaProjectAnswer>(ideaAnswersBox);

    return idea;
  }

  @HiveField(projectLatestFieldHiveId + 1)
  HiveList<IdeaProjectAnswer>? answers;

  /// keeps latest written text from [AnswerCreator]
  @HiveField(projectLatestFieldHiveId + 2)
  String newAnswerText;

  /// keeps latest selected [IdeaProjectQuestion] from [AnswerCreator]
  @HiveField(projectLatestFieldHiveId + 3)
  IdeaProjectQuestion? newQuestion;

  @override
  @HiveField(projectLatestFieldHiveId + 4)
  ProjectFolder? folder;

  @override
  String toShareString(final BuildContext context) => ideaProjectToShareString(
        context: context,
        projectIdea: toModel(),
      );

  @override
  List get props => [id];

  @override
  bool? get stringify => true;

  ProjectModelIdea toModel() => ProjectModelIdea(
        createdAt: created,
        id: ProjectModelId.fromJson(id),
        updatedAt: updated,
        answers: answers?.map((final e) => e.toModel()).toList() ?? [],
        title: title,
      );
}

String ideaProjectToShareString({
  required final ProjectModelIdea projectIdea,
  required final BuildContext context,
}) {
  final buffer = StringBuffer('${projectIdea.title} \n');
  final resolvedAnswers = projectIdea.answers;
  for (final answer in resolvedAnswers) {
    buffer.writeln(answer.toShareString(context));
  }

  return buffer.toString();
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
class MockIdeaProject extends Mock implements IdeaProject {}
