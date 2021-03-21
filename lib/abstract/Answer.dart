import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Question.dart';

part 'Answer.g.dart';

@HiveType(typeId: HiveBoxes.answerId)
class Answer extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String questionId;

  @HiveField(3)
  final String id;

  Answer({
    required this.title,
    required this.questionId,
    required this.id,
  });

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is Answer && other.id == id;
}
