import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/Question.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/models/QuestionsModel.dart';
import 'package:provider/provider.dart';

class AnswerCard extends StatelessWidget {
  final int index;
  final Answer answer;
  AnswerCard({required this.index, required this.answer});

  _showRemoveAnswer({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            Consumer<LocaleModel>(builder: (context, locale, child) {
              final answersModel =
                  Provider.of<AnswersModel>(context, listen: false);
              return AlertDialog(
                actions: [
                  FlatButton(
                    child: Text(MainLocalizations.of(context).cancel),
                    onPressed: () => Navigator?.of(context).pop(),
                  ),
                  FlatButton(
                    child: Text(MainLocalizations.of(context).delete),
                    onPressed: () async {
                      if (!kIsWeb) {
                        try {
                          final snackBar = SnackBar(
                            content: Text(MainLocalizations.of(context)
                                .successfullyDeleted),
                            duration: Duration(
                              seconds: 4,
                            ),
                            action: SnackBarAction(
                                label: 'ok',
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } catch (e) {
                          // its okay, if there is no snack bar
                        }
                      }
                      await answersModel.remove(answer);
                      Navigator?.of(context).pop();
                    },
                    color: Theme.of(context).buttonTheme.colorScheme?.error,
                  )
                ],
                title: Text(MainLocalizations.of(context)
                    .areYouSureYouWantToDeleteAnswer),
                content: Text(MainLocalizations.of(context)
                    .ifYouDeleteAnswerThereIsNoWayBack),
              );
            }));
  }

  List<DropdownMenuItem<Question>> _questionsListView(BuildContext context) {
    QuestionsModel questionsModel = Provider.of<QuestionsModel>(context);
    return questionsModel.questionDropdownMenuItems;
  }

  @override
  Widget build(BuildContext context) {
    final answersModel = Provider.of<AnswersModel>(context, listen: false);

    Question dropdownValue = answer.question;

    double dropdownWidth = 95.0;

    return Stack(children: <Widget>[
      Positioned(
        top: 4,
        left: 0,
        child: SizedBox(
            width: dropdownWidth - 10,
            child: DropdownButtonHideUnderline(
                child: DropdownButton<Question>(
              style:
                  TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
              itemHeight: null,
              value: dropdownValue,
              isExpanded: true,
              items: _questionsListView(context),
              onChanged: (Question? question) async {
                if (question != null) {
                  await answersModel.updateQuestion(answer, question);
                }
              },
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
            AnswerTextField(answer: answer)
          ],
        ),
      ),
      Positioned(
        top: 10,
        right: 5,
        child: IconButton(
          iconSize: 10,
          onPressed: () => _showRemoveAnswer(context: context),
          icon: Icon(
            Icons.close,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      )
    ]);
  }
}

class AnswerTextField extends StatefulWidget {
  final Answer answer;
  AnswerTextField({required this.answer});
  @override
  _AnswerTextFieldState createState() => _AnswerTextFieldState();
}

class _AnswerTextFieldState extends State<AnswerTextField> {
  TextEditingController _controller = TextEditingController();
  _updateAnswer() async {
    final answersModel = Provider.of<AnswersModel>(context, listen: false);
    if (_controller.text.isEmpty) {
      await answersModel.remove(widget.answer);
    } else {
      await answersModel.updateAnswer(
          oldAnswer: widget.answer, newAnswerTitle: _controller.text);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String answerText = widget.answer.title;
    // final copyText = '$questionTitle $answerText';
    _controller.text = answerText;

    return Flexible(
      //We only want to wrap the text message with flexible widget
      child: Focus(
        child: TextFormField(
          onChanged: (String text) async => await _updateAnswer(),
          textAlignVertical: TextAlignVertical.center,
          controller: _controller,
          maxLines: null,
          textAlign: TextAlign.justify,
          keyboardType: TextInputType.multiline,
          onEditingComplete: () async => await _updateAnswer(),
          style: TextStyle(
            fontSize: 14,
          ),
          decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              fillColor: Colors.transparent,
              focusColor: Colors.transparent),
          cursorColor: Theme.of(context).accentColor,
        ),
        onFocusChange: (hasFocus) async {
          if (!hasFocus) {
            await _updateAnswer();
          }
        },
      ),
    );
  }
}
