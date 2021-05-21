import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/abstract/project.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

String getAnswersAsString(
    {required BuildContext context, required Project project}) {
  final localeModel = Provider.of<LocaleModel>(context, listen: false);
  final questionModel = Provider.of<QuestionsModel>(context, listen: false);
  final lang = localeModel.currentNamedLocale.localeCode;
  final answersList = project.answers?.toList() ?? [];
  final answersAndQuestionsSentence =
      answersList.fold('', (previousValue, element) {
    final question = questionModel.getById(element.questionId);
    final str =
        '$previousValue\n${question.title.getProp(lang)} ${element.title} ';
    return str;
  });
  return answersAndQuestionsSentence;
}

Future<void> shareProjectAnswers(
    {required BuildContext context, required Project project}) async {
  final RenderBox? box = context.findRenderObject() as RenderBox?;
  if (box == null) return;
  final answersAndQuestionsSentence =
      getAnswersAsString(project: project, context: context);
  Share.share(answersAndQuestionsSentence,
      subject: project.title,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

void copyProjectAnswersToClipboard(
    {required BuildContext context, required Project project}) {
  final str = getAnswersAsString(context: context, project: project);
  final data = ClipboardData(text: str);
  Clipboard.setData(data);
}

Future<void> copyOrShareProjectAnswers(
    {required BuildContext context, required Project project}) async {
  if (isDesktop) {
    copyProjectAnswersToClipboard(context: context, project: project);
  } else {
    await shareProjectAnswers(context: context, project: project);
  }
}
