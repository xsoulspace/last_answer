import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/locale_tile.dart';
import 'package:lastanswer/abstract/question.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';

class QuestionsModelConsts {
  static const titleWhy = LocaleTitle(en: 'Why?', ru: 'Почему?');
  static const titleHow = LocaleTitle(en: 'How?', ru: 'Как?');
  static const titleWhere = LocaleTitle(en: 'Where?', ru: 'Где?');
  static const titleWhatFor = LocaleTitle(en: 'What for?', ru: 'Зачем?');
  static const titleForWhom =
      LocaleTitle(en: 'For whom | what?', ru: 'Для кого | чего?');
  static const titleWhat = LocaleTitle(en: 'What?', ru: 'Что?');
  static const List<Question> questions = [
    Question(title: titleWhy, id: '1'),
    Question(title: titleHow, id: '2'),
    Question(title: titleWhere, id: '3'),
    Question(title: titleWhatFor, id: '4'),
    Question(title: titleForWhom, id: '5'),
    Question(title: titleWhat, id: '6'),
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
          .map(
            (protoQuestion) => DropdownMenuItem<Question>(
              value: protoQuestion,
              child: Consumer<LocaleModel>(
                builder: (context, plocaleModel, child) => Text(
                  protoQuestion.title.getProp(
                    plocaleModel.locale.languageCode,
                  ),
                ),
              ),
            ),
          )
          .toList();

  void add(Question question) {
    QuestionsModelConsts.questions.add(question);
  }

  void clearAll() {
    QuestionsModelConsts.questions.clear();
  }
}
