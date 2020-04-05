import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:howtosolvequest/entities/Answer.dart';
import 'package:howtosolvequest/entities/LocaleTitle.dart';
import 'package:howtosolvequest/entities/Question.dart';

class AnswersModel extends ChangeNotifier {
  final List<Answer> _answers = [];
  Answer getById(int id) => _answers.firstWhere((item) => item.hashCode == id);
  Answer getPosition(int position) {
    return _answers[position];
  }

  Answer get lastAnswer {
    return _answers.length > 0
        ? _answers.last
        : Answer('', Question(LocaleTitle('', ''), 0), 0);
  }

  int length() => _answers.length;

  UnmodifiableListView<Answer> get answers => UnmodifiableListView(_answers);
  UnmodifiableListView<Answer> getAnswersByType(Question question) =>
      UnmodifiableListView(_answers.where(
          (Answer answer) => answer.question.hashCode == question.id)).toList();

  void add(String answer, Question question) {
    _answers.add(Answer(
      answer,
      question,
      _answers.length,
    ));
    notifyListeners();
  }

  void clearAll() {
    _answers.clear();
    notifyListeners();
  }
}
