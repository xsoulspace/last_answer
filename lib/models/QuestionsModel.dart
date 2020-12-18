import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/entities/LocaleTitle.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:provider/provider.dart';

import 'LocaleModel.dart';

class QuestionsModelConsts {
  static final List<Question> questions = [
    Question(title: LocaleTitle(en: 'Why?', ru: 'Почему?'), id: 1),
    Question(title: LocaleTitle(en: 'How?', ru: 'Как?'), id: 2),
    Question(title: LocaleTitle(en: 'Where?', ru: 'Где?'), id: 3),
    Question(title: LocaleTitle(en: 'What for?', ru: 'Зачем?'), id: 4),
    Question(
        title: LocaleTitle(en: 'For whom/ what?', ru: 'Для кого/чего?'), id: 5),
    Question(title: LocaleTitle(en: 'What?', ru: 'Что?'), id: 6),
  ];
}

class QuestionsModel extends ChangeNotifier {
  late Question chosenQuestion;
  QuestionsModel() {
    chosenQuestion = getById(1);
  }

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
                        protoQuestion.title.getProp(plocaleModel.current) ??
                            '')),
              ))
          .toList();

  void add(Question question) {
    QuestionsModelConsts.questions.add((question));
  }

  void clearAll() {
    QuestionsModelConsts.questions.clear();
  }
}
