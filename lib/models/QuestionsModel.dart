import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:howtosolvethequest/entities/LocaleTitle.dart';
import 'package:howtosolvethequest/entities/Question.dart';

class QuestionsModel extends ChangeNotifier {
  final List<Question> _questions = [
    Question(LocaleTitle('Why?', 'Почему?'), 1),
    Question(LocaleTitle('How?', 'Как?'), 2),
    Question(LocaleTitle('Where?', 'Где?'), 3),
    Question(LocaleTitle('What for?', 'Зачем?'), 5),
    Question(LocaleTitle('For whom/what?', 'Для кого/чего?'), 5),
    Question(LocaleTitle('What?', 'Что?'), 4),
  ];
  Question _chosenQuestion;
  QuestionsModel() {
    this._chosenQuestion = this.getById(1);
  }
  Question get chosenQuestion => this._chosenQuestion;
  set chosenQuestion(Question question) => this._chosenQuestion = question;

  Question getById(int id) =>
      _questions.firstWhere((item) => item.hashCode == id);
  Question getPosition(int position) {
    return _questions[position];
  }

  int length() => _questions.length;

  UnmodifiableListView<Question> get questions =>
      UnmodifiableListView(_questions);

  void add(Question question) {
    _questions.add((question));
  }

  void clearAll() {
    _questions.clear();
  }
}
