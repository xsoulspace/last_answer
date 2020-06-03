import 'package:howtosolvethequest/entities/LocaleTitle.dart';

class Question {
  LocaleTitle title;
  int id;
  Question(this.title, this.id);

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Question && other.id == id;
  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['title'] = title;
    m['id'] = id;
    return m;
  }
}
