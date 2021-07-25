import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';

part 'idea_project.g.dart';

@HiveType(typeId: HiveBoxes.projectId)
class IdeaProject extends BasicProject {
  IdeaProject({
    required final String id,
    required final String title,
    required final DateTime created,
    required final this.answers,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
        );

  @HiveField(projectLatestFieldHiveId + 1, defaultValue: [])
  HiveList<Answer> answers;
}
