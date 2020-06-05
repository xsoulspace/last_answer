import 'package:flutter/material.dart';
import 'package:howtosolvethequest/components/QuestionsComponent.dart';
import 'package:howtosolvethequest/entities/LocaleTitle.dart';
import 'package:howtosolvethequest/entities/Question.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/QuestionsModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AskScreen extends StatefulWidget {
  @override
  _AskScreenState createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;

  Future<void> loadLocaleAndAnswers() async {
    if (_isInitialized) return;
    LocaleModel localeModel = Provider.of<LocaleModel>(context);
    AnswersModel answersModel = Provider.of<AnswersModel>(context);
    print('we are here');
    await answersModel.ini();
    print('aaand are here');
    List<String> listLocale =Intl.defaultLocale.split("_");
    Locale locale = Locale(listLocale[0],listLocale[1]);
    print('new locale ${locale.toString()}');
    localeModel.switchLang(locale);
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    AnswersModel answersModel = Provider.of<AnswersModel>(context);

    return FutureBuilder(
        future: loadLocaleAndAnswers(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title:
                      Consumer<LocaleModel>(builder: (context, locale, child) {
                    return Text((MainLocalizations.of(context).lastAnswer));
                  }),
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/menu');
                      },
                      icon: Icon(Icons.done),
                      tooltip: 'complete',
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/answers');
                      },
                      child: Consumer<LocaleModel>(
                          builder: (context, locale, child) {
                        return Text((MainLocalizations.of(context).answers));
                      }),
                    ),
                  ],
                ),
                body: Container(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(answersModel.lastAnswer.title),
                            ),
                            QuestionsComponent(),
                            QuestionsAndInput()
                          ],
                        ))));
          } else {
            return _circularSpinner();
          }
        });
  }

  Widget _circularSpinner() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class QuestionsAndInput extends StatefulWidget {
  _QuestionsAndInput createState() => _QuestionsAndInput();
}

class _QuestionsAndInput extends State<QuestionsAndInput> {
  String inputText;
  Question question = Question(LocaleTitle('What?', 'Что?'), 0);
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    AnswersModel answers = Provider.of<AnswersModel>(context);
    QuestionsModel questions = Provider.of<QuestionsModel>(context);
    return Column(
      children: <Widget>[
        SizedBox(height: 1),
        Divider(),
        SizedBox(height: 10),
        Container(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questions.length(),
              itemBuilder: (context, index) => Container(
                  width: 120.0,
                  child: RaisedButton(onPressed: () {
                    setState(() {
                      question = questions.questions[index];
                    });
                  }, child:
                      Consumer<LocaleModel>(builder: (context, locale, child) {
                    return Text(
                      questions.questions[index].title.getProp(locale.current),
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
                border: OutlineInputBorder(),
                labelText: MainLocalizations.of(context).answer),
          );
        }))
      ],
    );
  }
}
