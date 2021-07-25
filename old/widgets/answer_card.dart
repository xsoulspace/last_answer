import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';
import 'package:lastanswer/abstract/question.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:lastanswer/widgets/card_dissmisible.dart';
import 'package:provider/provider.dart';

class AnswerCard extends StatelessWidget {
  final int index;
  final Answer answer;
  final Future<bool?> Function() confirmDelete;
  final void Function() onDismissed;
  final double dropdownWidth = isDesktop ? 120 : 95.0;

  AnswerCard({
    required this.index,
    required this.answer,
    required this.confirmDelete,
    required this.onDismissed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardDissmisible(
      dismissableKey: Key(answer.id),
      confirmDismiss: (direction) async {
        if (direction.index != 3) return false;
        return confirmDelete();
      },
      onDismissed: (direction) async {
        onDismissed();
      },
      child: Material(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 4,
              left: 0,
              child: SizedBox(
                width: dropdownWidth - 10,
                child: QuestionDropdown(
                  answer: answer,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(dropdownWidth, 1, 0, 1),
              child: AnswerTextField(
                answer: answer,
                onDelete: () async {
                  final toDelete = await confirmDelete();
                  if (toDelete == true) onDismissed();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionDropdown extends StatefulWidget {
  final Answer answer;
  const QuestionDropdown({
    required this.answer,
  });
  @override
  _QuestionDropdownState createState() => _QuestionDropdownState();
}

class _QuestionDropdownState extends State<QuestionDropdown> {
  late Question chosenQuestion;
  @override
  Widget build(BuildContext context) {
    final questionsModel = Provider.of<QuestionsModel>(context, listen: false);
    final question = questionsModel.getById(widget.answer.questionId);
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
      ),
    );
  }
}

class AnswerTextField extends StatefulWidget {
  final Answer answer;
  final void Function()? onDelete;
  const AnswerTextField({
    required this.answer,
    this.onDelete,
  });
  @override
  _AnswerTextFieldState createState() => _AnswerTextFieldState();
}

class _AnswerTextFieldState extends State<AnswerTextField> {
  final _controller = TextEditingController();
  Future<void> _updateAnswer({
    required Box<Answer> box,
  }) async {
    final _answer = widget.answer;
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
    final _answerBox = Hive.box<Answer>(HiveBoxes.answers);
    final answerText = widget.answer.title;
    _controller.text = answerText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Flexible(
            //We only want to wrap the text message with flexible widget
            child: Focus(
              onFocusChange: (bool hasFocus) async {
                if (hasFocus) return;
                await _updateAnswer(box: _answerBox);
              },
              child: TextFormField(
                onChanged: (String text) async {
                  await _updateAnswer(box: _answerBox);
                },
                textAlignVertical: TextAlignVertical.center,
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onEditingComplete: () async => _updateAnswer(box: _answerBox),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.color
                      ?.withOpacity(0.9),
                ),
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      iconSize: 10,
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    focusColor: Colors.transparent),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
