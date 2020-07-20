import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/LocaleTitle.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:lastanswer/utils/storage_util.dart';
import 'dart:convert';

class AnswersModelConsts {
  static String answers = 'answers';
}

class AnswersModel extends ChangeNotifier {
  final Map<int, Answer> _answers = {};
  bool isInitialized = false;
  List<Answer> get answersList => _answers.values.toList();
  StorageUtil _storage;
  AnswersModel() {
    StorageUtil.getInstance().then((inst) => _storage = inst);
  }

  Future<void> ini() async {
    if (_storage == null) {
      _storage = await StorageUtil.getInstance();
    }
    String answers = (_storage.getString(AnswersModelConsts.answers) ?? '');
    // print('answers, $answers');
    if (answers == null || answers == '') {
      return;
    }
    fromJson(jsonDecode(answers));
    notifyListeners();
  }

  Answer getById(int id) =>
      answersList.firstWhere((item) => item.hashCode == id);
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

  Future<void> add(String answer, Question question) async {
    int id = _answers.length;
    _answers.putIfAbsent(
        id,
        () => Answer(
              answer,
              question,
              id,
            ));
    await updateAnswersStorage();
    notifyListeners();
  }

  Future<void> update(Answer oldAnswer, String newAnswer) async {
    _answers.update(oldAnswer.id, (answer) {
      answer.title = newAnswer;
      return answer;
    });
    await updateAnswersStorage();

    // notifyListeners();
  }

  Future<void> updateQuestion(Answer oldAnswer, Question question) async {
    _answers.update(oldAnswer.id, (answer) {
      answer.question = question;
      return answer;
    });
    await updateAnswersStorage();
    notifyListeners();
  }

  Future<void> remove(Answer oldAnswer) async {
    _answers.remove(oldAnswer.id);
    await updateAnswersStorage();
    notifyListeners();
  }

  Future<void> clearAll() async {
    // print('cleaning');
    _answers.clear();
    // clearing storage
    // print('cleaning storage');
    await _storage.putString(AnswersModelConsts.answers, '');
    notifyListeners();
  }

  Future<void> updateAnswersStorage() async {
    String json = jsonEncode(toJson());
    await _storage.putString(AnswersModelConsts.answers, json);
  }

  toJson() => answersList.map((answer) => answer.toJson()).toList();

  fromJson(List answers) => answers.forEach((answer) {
        Answer newAnswer = Answer.fromJson(answer);
        _answers.putIfAbsent(newAnswer.id, () => newAnswer);
      });
}
