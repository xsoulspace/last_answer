import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class AnswersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MainLocalizations.of(context).answers),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _AnswersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var answers = Provider.of<AnswersModel>(context);
    var locale = Provider.of<LocaleModel>(context).current;
    return ListView.builder(
        itemCount: answers.length(),
        itemBuilder: (context, index) => Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      answers.answers[index].question.title.getProp(locale),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Text(
                    answers.answers[index].title,
                  ),
                ],
              ),
            )));
  }
}
