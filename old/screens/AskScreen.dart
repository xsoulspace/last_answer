// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:lastanswer/entities/Answer.dart';
// import 'package:lastanswer/entities/Question.dart';
// import 'package:lastanswer/localizations/MainLocalizations.dart';
// import 'package:lastanswer/main.dart';
// import 'package:lastanswer/models/AnswersModel.dart';
// import 'package:lastanswer/models/LocaleModel.dart';
// import 'package:lastanswer/models/QuestionsModel.dart';
// import 'package:lastanswer/widgets/AnswersList.dart';
// import 'package:provider/provider.dart';

// class AskScreen extends StatelessWidget {
//   Future<void> loadLocaleAndAnswers(
//       {required LocaleModel localeModel,
//       required AnswersModel answersModel}) async {
//     if (localeModel.isInitialized) return;

//     List<String> listLocale = Intl.defaultLocale.split("_");
//     Locale locale = Locale(listLocale[0], listLocale[1]);
//     await localeModel.switchLang(locale);
//     await answersModel.ini();

//     localeModel.isInitialized = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     LocaleModel localeModel = Provider.of<LocaleModel>(context);
//     AnswersModel answersModel = Provider.of<AnswersModel>(context);
//     return Container(
//         padding: EdgeInsets.only(left: 16.0, right: 16, bottom: 16.0, top: 5),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Expanded(
//               child: AnswersList(),
//             ),
//             if (!localeModel.isInitialized)
//               FutureBuilder(
//                   future: loadLocaleAndAnswers(
//                       answersModel: answersModel, localeModel: localeModel),
//                   builder:
//                       (BuildContext context, AsyncSnapshot<void> snapshot) {
//                     switch (snapshot.connectionState) {
//                       case ConnectionState.done:
//                         return Container();
//                       default:
//                         return CircularProgressIndicator();
//                     }
//                   }),
//             QuestionsAndInput()
//           ],
//         ));
//   }
// }

// class LastAnswer extends StatefulWidget {
//   final Answer answer;
//   LastAnswer({required this.answer});
//   @override
//   _LastAnswerState createState() => _LastAnswerState();
// }

// class _LastAnswerState extends State<LastAnswer>
//     with SingleTickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       widget.answer.title,
//       // softWrap: false,
//     );
//   }
// }
