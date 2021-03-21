import 'package:hive/hive.dart';
import 'package:last_answer/abstract/Answer.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';

part 'Project.g.dart';

@HiveType(typeId: HiveBoxes.projectId)
class Project extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  bool isCompleted;
  @HiveField(2)
  String title;

  @HiveField(3)
  HiveList<Answer>? answers;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  Project(
      {required this.id,
      required this.title,
      this.isCompleted = false,
      this.answers});
}
