import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/Answer.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/Question.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:provider/provider.dart';

final double dropdownWidth = 95.0;

class AnswerCard extends StatelessWidget {
  final int index;
  final Answer answer;
  AnswerCard({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: <Widget>[
        Positioned(
            top: 4,
            left: 0,
            child: SizedBox(
                width: dropdownWidth - 10,
                child: QuestionDropdown(
                  answer: answer,
                ))),
        Padding(
          padding: EdgeInsets.fromLTRB(dropdownWidth, 3, 50, 5),
          child: AnswerTextField(answer: answer),
        ),
        Visibility(
          visible: isDesktop(),
          child: Positioned(
            top: 10,
            right: 5,
            child: IconButton(
              iconSize: 10,
              onPressed: () =>
                  showRemoveAnswer(context: context, answer: answer),
              icon: Icon(
                Icons.close,
                color: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.color
                    ?.withOpacity(0.6),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class QuestionDropdown extends StatefulWidget {
  final Answer answer;
  QuestionDropdown({required this.answer});
  @override
  _QuestionDropdownState createState() => _QuestionDropdownState();
}

class _QuestionDropdownState extends State<QuestionDropdown> {
  late Question chosenQuestion;
  @override
  Widget build(BuildContext context) {
    QuestionsModel questionsModel =
        Provider.of<QuestionsModel>(context, listen: false);
    var question = questionsModel.getById(widget.answer.questionId);
    chosenQuestion = question;

    return DropdownButtonHideUnderline(
        child: DropdownButton<Question>(
      style: TextStyle(
          fontSize: 14, color: Theme.of(context).textTheme.headline6?.color),
      itemHeight: null,
      value: chosenQuestion,
      isExpanded: true,
      items: questionsModel.questionDropdownMenuItems,
      onChanged: (Question? question) async {
        if (question == null) return;
        widget.answer.questionId = question.id;
        widget.answer.save();
        setState(() {});
      },
    ));
  }
}

void showRemoveAnswer({required BuildContext context, required Answer answer}) {
  showDialog(
      context: context,
      builder: (BuildContext context) =>
          Consumer<LocaleModel>(builder: (context, locale, child) {
            return AlertDialog(
              actions: [
                TextButton(
                  child:
                      Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () => Navigator?.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                      MaterialLocalizations.of(context).deleteButtonTooltip),
                  onPressed: () async {
                    if (!kIsWeb) {
                      try {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)
                                  ?.successfullyDeleted ??
                              ''),
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
                    answer.delete();
                    Navigator?.of(context).pop();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).buttonTheme.colorScheme?.error)),
                )
              ],
              title: Text(AppLocalizations.of(context)
                      ?.areYouSureYouWantToDeleteAnswer ??
                  ''),
              content: Text(AppLocalizations.of(context)
                      ?.ifYouDeleteAnswerThereIsNoWayBack ??
                  ''),
            );
          }));
}

class AnswerTextField extends StatefulWidget {
  final Answer answer;
  AnswerTextField({required this.answer});
  @override
  _AnswerTextFieldState createState() => _AnswerTextFieldState();
}

class _AnswerTextFieldState extends State<AnswerTextField> {
  TextEditingController _controller = TextEditingController();
  _updateAnswer({required Box<Answer> box}) async {
    var _answer = widget.answer;
    _answer.title = _controller.text;
    await _answer.save();
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
    var _answerBox = Hive.box<Answer>(HiveBoxes.answers);
    String answerText = widget.answer.title;
    _controller.text = answerText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Flexible(
          //We only want to wrap the text message with flexible widget
          child: Focus(
            child: TextFormField(
              expands: false,
              onChanged: (String text) async {
                await _updateAnswer(box: _answerBox);
              },
              textAlignVertical: TextAlignVertical.center,
              controller: _controller,
              maxLines: null,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.multiline,
              onEditingComplete: () async =>
                  await _updateAnswer(box: _answerBox),
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.color
                      ?.withOpacity(0.9)),
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
            onFocusChange: (bool hasFocus) async {
              if (hasFocus) return;
              await _updateAnswer(box: _answerBox);
            },
          ),
        ),
      ]),
    );
  }
}
