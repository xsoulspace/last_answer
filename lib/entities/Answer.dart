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
  // toJSONEncodable() {
  //   Map<String, dynamic> m = new Map();

  //   m['title'] = title;
  //   m['question'] = question.toJSONEncodable();
  //   m['id'] = id;
  //   return m;
  // }
  // toJSONDecode(Map<String, dynamic> m) {

  //   title = m['title'];
  //   question = question.toJSONEncodable();
  //   id = m['id'];
  //   return m;
  // }
}
