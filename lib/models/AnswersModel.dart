import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:lastanswer/models/QuestionsModel.dart';
import 'package:lastanswer/models/StorageMixin.dart';

class AnswersModelConsts {
  static String answers = 'answers';
  static Answer emptyAnswer =
      Answer(id: 0, question: QuestionsModelConsts.questions.first, title: '');
}

class AnswersModel extends ChangeNotifier with StorageMixin {
  final Map<int, Answer> _answers = {};
  bool isInitialized = false;
  List<Answer> get answersList => _answers.values.toList();

  String currentWritingAnswer = '';

  Future<void> ini() async {
    print({'answers ini'});
    String answers =
        await (await storage).getString(AnswersModelConsts.answers);
    // print('answers, $answers');
    if (answers == '') {
      return;
    }
    // print({'answers': answers});

    fromJson(jsonDecode(answers));
    notifyListeners();
  }

  Answer getById(int id) =>
      answersList.firstWhere((item) => item.hashCode == id);
  // FIXME: remove function if it is not needed
  Answer? getPosition(int position) {
    return _answers[position];
  }

  Answer get lastAnswer {
    return answersList.length > 0
        ? answersList.last
        : AnswersModelConsts.emptyAnswer;
  }

  int length() => _answers.length;

  UnmodifiableListView<Answer> get answers => UnmodifiableListView(answersList);
  List<Answer> getAnswersByType(Question question) =>
      UnmodifiableListView(answersList.where(
          (Answer answer) => answer.question.hashCode == question.id)).toList();

  Future<void> add({required String answer, required Question question}) async {
    int id = _answers.length;
    _answers.putIfAbsent(
        id,
        () => Answer(
              title: answer,
              question: question,
              id: id,
            ));
    await updateAnswersStorage();
    notifyListeners();
  }

  Future<void> update(
      {required Answer oldAnswer, required String newAnswerTitle}) async {
    _answers.update(oldAnswer.id, (answer) {
      answer.title = newAnswerTitle;
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
    await (await storage).putString(AnswersModelConsts.answers, '');
    notifyListeners();
  }

  Future<void> updateAnswersStorage() async {
    String json = jsonEncode(toJson());
    await (await storage).putString(AnswersModelConsts.answers, json);
  }

  toJson() => answersList.map((answer) => answer.toJson()).toList();

  fromJson(List answers) => answers.forEach((answer) {
        Answer newAnswer = Answer.fromJson(answer);
        _answers.putIfAbsent(newAnswer.id, () => newAnswer);
      });
}
