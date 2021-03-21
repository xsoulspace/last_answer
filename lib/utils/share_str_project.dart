import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/models/questions_model.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:universal_io/io.dart';

String getAnswersAsString(
    {required BuildContext context, required Project project}) {
  var localeModel = Provider.of<LocaleModel>(context, listen: false);
  var questionModel = Provider.of<QuestionsModel>(context, listen: false);
  var lang = localeModel.currentNamedLocale.name;
  var answersList = project.answers?.toList() ?? [];
  String answersAndQuestionsSentence =
      answersList.fold('', (previousValue, element) {
    var question = questionModel.getById(element.questionId);
    var str =
        '$previousValue\n${question.title.getProp(lang)} ${element.title} ';
    return str;
  });
  return answersAndQuestionsSentence;
}

Future<void> shareProjectAnswers(
    {required BuildContext context, required Project project}) async {
  final RenderBox? box = context.findRenderObject() as RenderBox?;
  if (box == null) return;
  String answersAndQuestionsSentence =
      getAnswersAsString(project: project, context: context);
  Share.share(answersAndQuestionsSentence,
      subject: project.title,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

void copyProjectAnswersToClipboard(
    {required BuildContext context, required Project project}) {
  var str = getAnswersAsString(context: context, project: project);
  var data = ClipboardData(text: str);
  Clipboard.setData(data);
}

Future<void> copyOrShareProjectAnswers(
    {required BuildContext context, required Project project}) async {
  if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    copyProjectAnswersToClipboard(context: context, project: project);
  } else {
    await shareProjectAnswers(context: context, project: project);
  }
}
