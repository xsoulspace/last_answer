import 'package:lastanswer/abstract/LocaleTitle.dart';

class Question {
  LocaleTitle title;
  final String id;
  Question({required this.title, required this.id});

  @override
  int get hashCode => id.hashCode;

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
