import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:howtosolvethequest/entities/LocaleTitle.dart';
import 'package:howtosolvethequest/entities/Question.dart';
import 'package:howtosolvethequest/utils/storage_util.dart';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';

class Consts {
  static String answers = 'answers';
}

class AnswersModel extends ChangeNotifier {
  // LocalStorage storage;
  final Map<String, Answer> _answers = {};
  List<Answer> get answersList => _answers.values.toList();
  StorageUtil _storage;
  AnswersModel() {
    // storage = new LocalStorage('htstq_app');
    StorageUtil.getInstance().then((inst) => _storage = inst);
  }

  Future<void> ini() async {
    if (_storage == null) {
      _storage = await StorageUtil.getInstance();
    }
    String answers = (_storage.getString(Consts.answers) ?? '');
    // List answers = storage.getItem(Consts.answers);
    print('answers, $answers');
    // print('olaola $answersStr');
    // if (answersStr == '') return;
    if (answers == null) {
      return;
    }
    // var answers = jsonDecode(answersStr);
    // print({answers, answersStr});
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
    _answers.putIfAbsent(
        answer,
        () => Answer(
              answer,
              question,
              _answers.length,
            ));
    // String encodedStr = jsonEncode(_answers.toString());
    // saving to storage
    // await _storage.putString(Consts.answers, encodedStr);
    String json = jsonEncode(toJson());
    print(json);
    await _storage.putString(Consts.answers, json);

    // await storage.setItem(Consts.answers, json);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _answers.clear();
    // clearing storage
    // await storage.clear();
    await _storage.putString(Consts.answers, '');
    notifyListeners();
  }

  toJson() => answersList.map((answer) => answer.toJson()).toList();

  fromJson(List answers) => answers.forEach((answer) {
        Answer newAnswer = Answer.fromJson(answer);
        _answers.putIfAbsent(newAnswer.title, () => newAnswer);
      });
}
