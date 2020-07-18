import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
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

class _AnswersList extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AnswersModel answers = Provider.of<AnswersModel>(context);
    String locale = Provider.of<LocaleModel>(context).current;

    Widget textRow(dynamic index) {
      final originalAnswer = answers.answers[index];
      final questionTitle = originalAnswer.question.title.getProp(locale);
      final answerText = originalAnswer.title;
      _controller.text = answerText;
      final copyText = '$questionTitle $answerText';
      return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Stack(children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 14, 35, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: 80,
                    child: Text(
                      questionTitle,
                    ),
                  ),
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
                    onChanged: (inputText) async {
                      if (inputText == null || inputText == '') return;
                      await answers.update(originalAnswer, inputText);
                    },
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.lightGreen[50]),
                      fillColor: Colors.lightGreen[50],
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.lightGreen[50],
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen[50])),
                      // labelText: MainLocalizations.of(context).answer
                    ),
                    cursorColor: Theme.of(context).accentColor,
                  ))),
                ],
              ),
            ),
            CopyIcon(copyText)
          ]));
    }

    return ListView.builder(
        itemCount: answers.length(),
        itemBuilder: (context, index) => textRow(index));
  }
}
