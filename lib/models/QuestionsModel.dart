import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:howtosolvequest/entities/Question.dart';

class QuestionsModel extends ChangeNotifier {
  final List<Question> _questions = [
    Question('Why?', 1),
    Question('Where?', 2),
    Question('How?', 3),
    Question('How to?', 4),
    Question('What?', 5),
    Question('For what?', 5),
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
