import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:howtosolvethequest/entities/Question.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/main.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/QuestionsModel.dart';
import 'package:provider/provider.dart';

class AnswersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class CopyIcon extends StatefulWidget {
  final _copyText;
  CopyIcon(this._copyText);
  @override
  _CopyIconState createState() => _CopyIconState(_copyText);
}

enum CopyIconStatuses { copy, done }

class _CopyIconState extends State<CopyIcon> with TickerProviderStateMixin {
  final _copyText;
  _CopyIconState(this._copyText);
  CopyIconStatuses _iconStatus = CopyIconStatuses.copy;
  Timer _timer;
  cancelTimer() {
    if (_timer != null && _timer.isActive) _timer.cancel();
  }

  Future<void> copyPressed() async {
    cancelTimer();
    await Clipboard.setData(ClipboardData(text: _copyText));
    setState(() {
      _iconStatus = CopyIconStatuses.done;
    });
    void returnIconCopy(Timer t) {
      setState(() {
        _iconStatus = CopyIconStatuses.copy;
      });
      cancelTimer();
    }

    _timer = Timer.periodic(Duration(milliseconds: 1300), returnIconCopy);
  }

  dispose() {
    cancelTimer();
    super.dispose();
  }

//
  Widget copyIcon() {
    return Positioned(
      right: 0,
      top: 0,
      child: AnimatedSwitcher(
        child: _iconStatus == CopyIconStatuses.copy
            ? IconButton(
                icon: Icon(
                  Icons.content_copy,
                ),
                onPressed: () async => await copyPressed())
            : IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.lightGreen[300],
                ),
                onPressed: () async => await copyPressed()),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return copyIcon();
  }
}

class AnswerTextField extends StatefulWidget {
  final int index;
  AnswerTextField(this.index);
  @override
  _AnswerTextFieldState createState() => _AnswerTextFieldState(index);
}

class _AnswerTextFieldState extends State<AnswerTextField> {
  final int index;
  _AnswerTextFieldState(this.index);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  // Find the Scaffold in the widget tree and use it to show a SnackBar.

  @override
  Widget build(BuildContext context) {
    AnswersModel answersModel = Provider.of<AnswersModel>(context);
    QuestionsModel questionsModel = Provider.of<QuestionsModel>(context);
    Answer originalAnswer = answersModel.answers[index];
    _removeAnswer() {
      return Positioned(
          top: 20,
          right: 0,
          child: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      Consumer<LocaleModel>(builder: (context, locale, child) {
                        return AlertDialog(
                          actions: [
                            FlatButton(
                              child: Text(MainLocalizations.of(context).cancel),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text(MainLocalizations.of(context).delete),
                              onPressed: () async {
                                if (!kIsWeb) {
                                  final snackBar = SnackBar(
                                      content: Text(
                                          MainLocalizations.of(context)
                                              .successfullyDeleted));

                                  Scaffold.of(context).showSnackBar(snackBar);
                                }
                                await answersModel.remove(originalAnswer);
                                Navigator.of(context).pop();
                              },
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme
                                  .error,
                            )
                          ],
                          title: Text(MainLocalizations.of(context)
                              .areYouSureYouWantToDeleteAnswer),
                          content: Text(MainLocalizations.of(context)
                              .ifYouDeleteAnswerThereIsNoWayBack),
                        );
                      }));
            },
            icon: Icon(Icons.delete),
          ));
    }

    final answerText = originalAnswer.title;
    // final copyText = '$questionTitle $answerText';
    setState(() {
      _controller.text = answerText;
    });

    _updateAnswer() async {
      if (_controller.text.isEmpty) {
        await answersModel.remove(originalAnswer);
      } else {
        await answersModel.update(originalAnswer, _controller.text);
      }
    }

    print(originalAnswer.question.toJson());
    return Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 14, 50, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                    width: 90,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<Question>(
                      itemHeight: null,
                      value: (originalAnswer != null &&
                              originalAnswer.question != null)
                          ? originalAnswer.question
                          : null,
                      isExpanded: true,
                      items: questionsModel.questions
                          .map((question) => DropdownMenuItem<Question>(
                                value: question,
                                child: Consumer<LocaleModel>(
                                    builder: (context, localeModel, child) =>
                                        Text(question.title
                                            .getProp(localeModel.current))),
                              ))
                          .toList(),
                      onChanged: (Question question) async => await answersModel
                          .updateQuestion(originalAnswer, question),
                    ))),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                ),
                Flexible(
                    //We only want to wrap the text message with flexible widget
                    child: Container(
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 7,
                    keyboardType: TextInputType.multiline,
                    onEditingComplete: () async => await _updateAnswer(),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: ThemeColors.lightAccent),
                      fillColor: ThemeColors.lightAccent,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ThemeColors.lightAccent,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ThemeColors.lightAccent)),
                    ),
                    cursorColor: Theme.of(context).accentColor,
                    // labelText: MainLocalizations.of(context).answer
                  ),
                )),
              ],
            ),
          ),
          // CopyIcon(copyText),
          _removeAnswer()
        ]));
  }
}

class _AnswersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnswersModel answers = Provider.of<AnswersModel>(context);

    return ListView.builder(
        itemCount: answers.length(),
        itemBuilder: (context, index) => AnswerTextField(index));
  }
}
