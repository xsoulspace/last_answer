import 'package:lastanswer/entities/LocaleTitle.dart';

class Question {
  LocaleTitle title;
  int id;
  Question(this.title, this.id);

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Question && other.id == id;
  Map<String, dynamic> toJson() => {
        'title': title.toJson(),
        'id': id,
      };

  Question.fromJson(Map<String, dynamic> m)
      : title = LocaleTitle.fromJson(m['title']),
        id = m['id'];
}
