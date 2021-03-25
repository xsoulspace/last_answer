import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/LocaleTitle.dart';
import 'package:lastanswer/abstract/Question.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';

class QuestionsModelConsts {
  static final List<Question> questions = [
    Question(title: LocaleTitle(en: 'Why?', ru: 'Почему?'), id: '1'),
    Question(title: LocaleTitle(en: 'How?', ru: 'Как?'), id: '2'),
    Question(title: LocaleTitle(en: 'Where?', ru: 'Где?'), id: '3'),
    Question(title: LocaleTitle(en: 'What for?', ru: 'Зачем?'), id: '4'),
    Question(
        title: LocaleTitle(en: 'For whom | what?', ru: 'Для кого | чего?'),
        id: '5'),
    Question(title: LocaleTitle(en: 'What?', ru: 'Что?'), id: '6'),
  ];
}

class QuestionsModel extends ChangeNotifier {
  late Question chosenQuestion;
  QuestionsModel() {
    chosenQuestion = getById('1');
  }
  int getIndexById(String id) {
    return questions.indexWhere((element) => element.id == id);
  }

  Question getById(String id) => QuestionsModelConsts.questions
      .firstWhere((item) => item.hashCode == id.hashCode);
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
                        protoQuestion.title
                                .getProp(plocaleModel.locale.languageCode) ??
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
