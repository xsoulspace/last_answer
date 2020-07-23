import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/main.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/models/QuestionsModel.dart';
import 'package:provider/provider.dart';

class AnswersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild.unfocus();
          }
        },
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _AnswersList(),
                ),
              ),
            ],
          ),
        ));
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
  TextEditingController _controller = TextEditingController();
  AnswersModel answersModel;
  Answer originalAnswer;

  _updateAnswer() async {
    if (_controller.text.isEmpty) {
      await answersModel.remove(originalAnswer);
    } else {
      await answersModel.update(originalAnswer, _controller.text);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller?.dispose();

    super.dispose();
  }

  _showRemoveAnswer(BuildContext buildCtx) => showDialog(
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
                          content: Text(MainLocalizations.of(context)
                              .successfullyDeleted));

                      Scaffold.of(buildCtx).showSnackBar(snackBar);
                    }
                    await answersModel.remove(originalAnswer);
                    Navigator.of(context).pop();
                  },
                  color: Theme.of(context).buttonTheme.colorScheme.error,
                )
              ],
              title: Text(MainLocalizations.of(context)
                  .areYouSureYouWantToDeleteAnswer),
              content: Text(MainLocalizations.of(context)
                  .ifYouDeleteAnswerThereIsNoWayBack),
            );
          }));
  @override
  Widget build(BuildContext context) {
    answersModel = Provider.of<AnswersModel>(context);
    originalAnswer = answersModel.answers[index];

    QuestionsModel questionsModel = Provider.of<QuestionsModel>(context);
    LocaleModel localeModel = Provider.of<LocaleModel>(context);
    _removeAnswer() {
      return Positioned(
          top: 1,
          right: 0,
          child: Builder(
              builder: (buildCtx) => IconButton(
                    onPressed: () => _showRemoveAnswer(buildCtx),
                    icon: Icon(Icons.delete),
                  )));
    }

    String answerText = originalAnswer.title;
    // final copyText = '$questionTitle $answerText';
    _controller.text = answerText;
    bool isDropdownValueNull =
        originalAnswer == null || originalAnswer.question == null;
    Question dropdownValue =
        (!isDropdownValueNull) ? originalAnswer.question : null;

    double dropdownWidth = (() {
      return 95.0;
    })();
    return Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        // color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(children: <Widget>[
          Positioned(
            top: 4,
            left: 5,
            child: SizedBox(
                width: dropdownWidth,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<Question>(
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  itemHeight: null,
                  value: dropdownValue,
                  isExpanded: true,
                  items: questionsModel.questions
                      .map((question) => DropdownMenuItem<Question>(
                            value: question,
                            child: Consumer<LocaleModel>(
                                builder: (context, plocaleModel, child) => Text(
                                    question.title
                                        .getProp(plocaleModel.current))),
                          ))
                      .toList(),
                  onChanged: (Question question) async => await answersModel
                      .updateQuestion(originalAnswer, question),
                ))),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(dropdownWidth, 0, 40, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 5),
                ),
                Flexible(
                  //We only want to wrap the text message with flexible widget
                  child: Container(
                      child: Focus(
                    child: TextFormField(
                      onChanged: (String text) async => await _updateAnswer(),
                      textAlignVertical: TextAlignVertical.center,
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onEditingComplete: () async => await _updateAnswer(),
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: ThemeColors.lightAccent,
                      ),
                      cursorColor: Theme.of(context).accentColor,
                    ),
                    onFocusChange: (hasFocus) async {
                      if (!hasFocus) {
                        await _updateAnswer();
                      }
                    },
                  )),
                ),
              ],
            ),
          ),
          _removeAnswer()

          // CopyIcon(copyText),
        ]));
  }
}

class _AnswersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnswersModel answersModel = Provider.of<AnswersModel>(context);
    return ListView.builder(
        addSemanticIndexes: true,
        itemCount: answersModel.length(),
        itemBuilder: (context, index) => AnswerTextField(index));
  }
}
