import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';

part 'project.g.dart';

@HiveType(typeId: HiveBoxes.projectId)
class Project extends HiveObject with EquatableMixin {
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

  Project({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.answers,
    required this.created,
  });

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
