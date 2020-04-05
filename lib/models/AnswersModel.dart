import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:howtosolvequest/entities/Answer.dart';
import 'package:howtosolvequest/entities/LocaleTitle.dart';
import 'package:howtosolvequest/entities/Question.dart';

class AnswersModel extends ChangeNotifier {
  final Map<String, Answer> _answers = {};
  get answersList=> _answers.values.toList();

  Answer getById(int id) => answersList.firstWhere((item) => item.hashCode == id);
  Answer getPosition(int position) {
    return _answers[position];
  }

  Answer get lastAnswer {
    return answersList.length > 0
        ? answersList.last
        : Answer('', Question(LocaleTitle('', ''), 0), 0);
  }

  int length() => _answers.length;

  UnmodifiableListView<Answer> get answers => UnmodifiableListView(answersList);
  UnmodifiableListView<Answer> getAnswersByType(Question question) =>
      UnmodifiableListView(answersList.where(
          (Answer answer) => answer.question.hashCode == question.id)).toList();

  void add(String answer, Question question) {
    _answers.putIfAbsent(answer, () => Answer(
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
