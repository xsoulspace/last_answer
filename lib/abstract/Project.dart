import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';

@HiveType(typeId: HiveBoxes.projectId)
class Project {
  @HiveField(0)
  final int id;
  @HiveField(1)
  bool isCompleted;
  @HiveField(2)
  String title;

  @HiveField(3)
  HiveList answers;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  Project(
      {required this.id,
      required this.title,
      this.isCompleted = false,
      required this.answers});
}
