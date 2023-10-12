// ignore_for_file: overridden_fields
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:mockito/mockito.dart';

export 'idea_project_answer.dart';
export 'idea_project_question.dart';

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
  String toShareString() {
    final buffer = StringBuffer('$title \n');
    final List<IdeaProjectAnswer> resolvedAnswers = answers ?? [];
    for (final answer in resolvedAnswers) {
      buffer.writeln(answer.toShareString());
    }

    return buffer.toString();
  }

  @override
  List get props => [id];

  @override
  bool? get stringify => true;
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
class MockIdeaProject extends Mock implements IdeaProject {}
