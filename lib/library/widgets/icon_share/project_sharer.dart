part of widgets;

@immutable
class ProjectSharer {
  const ProjectSharer({required final this.project});
  final BasicProject project;
  // String getAnswersAsString({
  //   required final BuildContext context,
  // }) {
  //   final localeModel = Provider.of<LocaleModel>(context, listen: false);
  //   final questionModel = Provider.of<QuestionsModel>(context, listen: false);
  //   final lang = localeModel.currentNamedLocale.localeCode;
  //   final answersList = project.answers?.toList() ?? [];
  //   final answersAndQuestionsSentence =
  //       answersList.fold('', (final previousValue, final element) {
  //     final question = questionModel.getById(element.questionId);
  //     final str =
  //         '$previousValue\n${question.title.getProp(lang)} ${element.title} ';
  //     return str;
  //   });
  //   return answersAndQuestionsSentence;
  // }

  // Future<void> shareProjectAnswers(
  //     {required final BuildContext context,
  //     required final Project project}) async {
  //   final RenderBox? box = context.findRenderObject() as RenderBox?;
  //   if (box == null) return;
  //   final answersAndQuestionsSentence =
  //       getAnswersAsString(project: project, context: context);
  //   Share.share(answersAndQuestionsSentence,
  //       subject: project.title,
  //       sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  // }

  // void copyProjectAnswersToClipboard(
  //     {required final BuildContext context, required final Project project}) {
  //   final str = getAnswersAsString(context: context, project: project);
  //   final data = ClipboardData(text: str);
  //   Clipboard.setData(data);
  // }

  // Future<void> copyOrShareProjectAnswers(
  //     {required final BuildContext context,
  //     required final Project project}) async {
  //   if (isDesktop) {
  //     copyProjectAnswersToClipboard(context: context, project: project);
  //   } else {
  //     await shareProjectAnswers(context: context, project: project);
  //   }
  // }
}
