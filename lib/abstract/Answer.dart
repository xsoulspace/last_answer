import 'package:last_answer/abstract/Question.dart';

import 'Project.dart';

class Answer {
  String title;
  Question question;
  final Project project;
  final int id;
  Answer(
      {required this.title,
      required this.question,
      required this.id,
      required this.project});

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Answer && other.id == id;

  Map<String, dynamic> toJson() => {
        'title': title,
        'question': question.toJson(),
        'project': project.toJson(),
        'id': id,
      };

  Answer.fromJson(Map<String, dynamic> m)
      : title = m['title'],
        project = Project.fromJson(m['project']),
        question = Question.fromJson(m['question']),
        id = m['id'];
}
