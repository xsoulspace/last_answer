import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/entities/LocaleTitle.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:provider/provider.dart';

import 'LocaleModel.dart';

class QuestionsModelConsts {
  static final List<Question> questions = [
    Question(LocaleTitle('Why?', 'Почему?'), 1),
    Question(LocaleTitle('How?', 'Как?'), 2),
    Question(LocaleTitle('Where?', 'Где?'), 3),
    Question(LocaleTitle('What for?', 'Зачем?'), 4),
    Question(LocaleTitle('For whom/ what?', 'Для кого/чего?'), 5),
    Question(LocaleTitle('What?', 'Что?'), 6),
  ];
}

class QuestionsModel extends ChangeNotifier {
  Question _chosenQuestion;
  QuestionsModel() {
    this._chosenQuestion = this.getById(1);
  }
  Question get chosenQuestion => this._chosenQuestion;
  set chosenQuestion(Question question) => this._chosenQuestion = question;

  Question getById(int id) =>
      QuestionsModelConsts.questions.firstWhere((item) => item.hashCode == id);
  Question getPosition(int position) {
    return QuestionsModelConsts.questions[position];
  }

  int get length => QuestionsModelConsts.questions.length;

  UnmodifiableListView<Question> get questions =>
      UnmodifiableListView(QuestionsModelConsts.questions);
  List<DropdownMenuItem<Question>> get questionDropdownMenuItems =>
      QuestionsModelConsts.questions
          .map((protoQuestion) => DropdownMenuItem<Question>(
                value: protoQuestion,
                child: Consumer<LocaleModel>(
                    builder: (context, plocaleModel, child) => Text(
                        protoQuestion.title.getProp(plocaleModel.current))),
              ))
          .toList();

  void add(Question question) {
    QuestionsModelConsts.questions.add((question));
  }

  void clearAll() {
    QuestionsModelConsts.questions.clear();
  }
}
