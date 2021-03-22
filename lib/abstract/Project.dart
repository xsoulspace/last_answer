import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/Answer.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';

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

  @HiveField(4)
  final DateTime created;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  Project(
      {required this.id,
      required this.title,
      this.isCompleted = false,
      this.answers,
      required this.created});
}
