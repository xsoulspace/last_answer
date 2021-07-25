import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';

part 'project.g.dart';

const _depreceatedMessage =
    'This class should be used only for migration purpose, '
    'from old structure to new one. For all new projects use [BasicProject] '
    'classes such as [NoteProject], [StoryProject], [IdeaProject]';

/// This class was supposed to keep answers for all questions
@HiveType(typeId: HiveBoxes.projectId)
@Deprecated(_depreceatedMessage)
class Project extends HiveObject with EquatableMixin {
  @Deprecated(_depreceatedMessage)
  Project({
    required final this.id,
    required final this.title,
    required final this.created,
    final this.isCompleted = false,
    final this.answers,
  });
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
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
