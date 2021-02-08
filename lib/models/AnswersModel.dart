import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:last_answer/abstract/Answer.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/abstract/Question.dart';
import 'package:last_answer/models/QuestionsModel.dart';
import 'package:last_answer/models/StorageMixin.dart';

class AnswersModelConsts {
  static final String answers = 'answers';
  static final String currentWritingAnswer = 'currentWritingAnswer';

  static Answer emptyAnswer = Answer(
      id: 0,
      question: QuestionsModelConsts.questions.first,
      title: '',
      project: Project(id: 0, title: ''));
}

class AnswersModel extends ChangeNotifier with StorageMixin {
  final Map<int, Answer> _answers = {};
  UnmodifiableListView<Answer> get answers => UnmodifiableListView(answersList);
  List<Answer> get answersReversed => answersList.reversed.toList();
  List<Answer> get answersList => _answers.values.toList();

  List<Answer> getAnswersByType(Question question) =>
      UnmodifiableListView(answersList.where(
          (Answer answer) => answer.question.hashCode == question.id)).toList();

  bool isInitialized = false;
  String currentWritingAnswer = '';
  Future<void> updateCurrentWritingAnswer(String value) async {
    currentWritingAnswer = value;
    // notifyListeners();
    await (await storage)
        .putString(AnswersModelConsts.currentWritingAnswer, value);
  }

  Future<void> ini() async {
    print({'answers ini'});
    String answers =
        await (await storage).getString(AnswersModelConsts.answers);
    if (answers.isNotEmpty) fromJson(jsonDecode(answers));

    String _currentWritingAnswer = await (await storage)
        .getString(AnswersModelConsts.currentWritingAnswer);
    if (_currentWritingAnswer.isNotEmpty)
      currentWritingAnswer = _currentWritingAnswer;

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

  Future<void> add(
      {required String answer,
      required Question question,
      required Project project}) async {
    int id = _answers.length;
    _answers.putIfAbsent(
        id,
        () => Answer(
            title: answer, question: question, id: id, project: project));
    notifyListeners();

    await updateAnswersStorage();
  }

  Future<void> updateAnswer(
      {required Answer oldAnswer, required String newAnswerTitle}) async {
    _answers.update(oldAnswer.id, (answer) {
      answer.title = newAnswerTitle;
      return answer;
    });
    // notifyListeners();
    await updateAnswersStorage();
  }

  Future<void> updateQuestion(Answer oldAnswer, Question question) async {
    _answers.update(oldAnswer.id, (answer) {
      answer.question = question;
      return answer;
    });
    notifyListeners();

    await updateAnswersStorage();
  }

  Future<void> remove(Answer oldAnswer) async {
    _answers.remove(oldAnswer.id);
    notifyListeners();

    await updateAnswersStorage();
  }

  Future<void> clearAll() async {
    // print('cleaning');
    _answers.clear();
    currentWritingAnswer = '';
    // clearing storage
    // print('cleaning storage');
    notifyListeners();

    await (await storage).putString(AnswersModelConsts.answers, '');
    await (await storage)
        .putString(AnswersModelConsts.currentWritingAnswer, '');
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
