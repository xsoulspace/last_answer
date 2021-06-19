import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';

part 'answer.g.dart';

@HiveType(typeId: HiveBoxes.answerId)
class Answer extends HiveObject with EquatableMixin {
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

  Answer({
    required this.title,
    required this.questionId,
    required this.id,
    required this.created,
    required this.positionIndex,
  });
  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
