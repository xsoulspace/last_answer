import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Question.dart';

@HiveType(typeId: HiveBoxes.answerId)
class Answer {
  @HiveField(0)
  String title;

  @HiveField(1)
  Question question;

  @HiveField(3)
  final int id;

  Answer({
    required this.title,
    required this.question,
    required this.id,
  });

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Answer && other.id == id;
}
