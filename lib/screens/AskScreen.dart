import 'package:flutter/material.dart';
import 'package:lastanswer/components/QuestionsComponent.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/main.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/models/QuestionsModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AskScreen extends StatelessWidget {
  Future<void> loadLocaleAndAnswers(context) async {
    AnswersModel answersModel =
        Provider.of<AnswersModel>(context, listen: false);

    if (answersModel.isInitialized) return;
    LocaleModel localeModel = Provider.of<LocaleModel>(context);
    List<String> listLocale = Intl.defaultLocale.split("_");
    Locale locale = Locale(listLocale[0], listLocale[1]);
    await localeModel.switchLang(locale);
    await answersModel.ini();
    answersModel.isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    AnswersModel answersModel = Provider.of<AnswersModel>(context);
    return Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                    child: !answersModel.isInitialized
                        ? FutureBuilder(
                            future: loadLocaleAndAnswers(context),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.done:
                                  return LastAnswer();
                                default:
                                  return CircularProgressIndicator();
                              }
                            })
                        : LastAnswer()),
                QuestionsComponent(),
                QuestionsAndInput()
              ],
            )));
  }
}

class LastAnswer extends StatefulWidget {
  @override
  _LastAnswerState createState() => _LastAnswerState();
}

class _LastAnswerState extends State<LastAnswer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnswersModel>(
      builder: (context, answersModel, child) => Text(
        answersModel.lastAnswer.title ?? '',
        // softWrap: false,
      ),
    );
  }
}

class QuestionsAndInput extends StatefulWidget {
  _QuestionsAndInput createState() => _QuestionsAndInput();
}

class _QuestionsAndInput extends State<QuestionsAndInput> {
  String inputText;
  Question question = QuestionsModelConsts.questions[0];

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    AnswersModel answers = Provider.of<AnswersModel>(context);

    QuestionsModel questionsModel = Provider.of<QuestionsModel>(context);
    return Column(
      children: <Widget>[
        SizedBox(height: 1),
        Divider(),
        SizedBox(height: 10),
        Container(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questionsModel.length(),
              itemBuilder: (context, index) => Container(
                  width: 120.0,
                  child: RaisedButton(onPressed: () {
                    setState(() {
                      question = questionsModel.questions[index];
                    });
                  }, child:
                      Consumer<LocaleModel>(builder: (context, locale, child) {
                    return Text(
                      questionsModel.questions[index].title
                          .getProp(locale.current),
                    );
                  }))),
            )),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<LocaleModel>(builder: (context, locale, child) {
              return Text(question.title.getProp(locale.current));
            }),
            IconButton(
              onPressed: () async {
                if (inputText == null || inputText.isEmpty) return;
                await answers.add(inputText, question);
                _controller.clear();
              },
              icon: Icon(Icons.send),
            ),
          ],
        ),
        SizedBox(height: 10),
        Center(child: Consumer<LocaleModel>(builder: (context, locale, child) {
          return TextFormField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 7,
            keyboardType: TextInputType.multiline,
            onChanged: (text) {
              inputText = text;
            },
            decoration: InputDecoration(
                labelStyle: TextStyle(color: ThemeColors.lightAccent),
                fillColor: ThemeColors.lightAccent,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ThemeColors.lightAccent,
                  ),
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: ThemeColors.lightAccent)),
                labelText: MainLocalizations.of(context).answer),
            cursorColor: Theme.of(context).accentColor,
          );
        }))
      ],
    );
  }
}
