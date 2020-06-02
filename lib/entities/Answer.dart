import 'package:howtosolvethequest/entities/Question.dart';

class Answer {
  String title;
  Question question;
  int id;
  Answer(this.title, this.question, this.id);

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Answer && other.id == id;
}
