import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/Answer.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/models/questions_model.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';
import 'package:last_answer/widgets/share_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewAnswerField extends StatefulWidget {
  final Project project;
  NewAnswerField({required this.project});
  @override
  _NewAnswerFieldState createState() => _NewAnswerFieldState();
}

class _NewAnswerFieldState extends State<NewAnswerField> {
  final TextEditingController _titleController = TextEditingController();
  final uuid = Uuid();

  String questionId = QuestionsModelConsts.questions[5].id;
  final ScrollController _questionsScrollController = ScrollController();
  Future<void> updateCurrentAnswer(
      {required Box<Answer> box, required String title}) async {
    await box.put(
        BoxAnswer.currentAnswer,
        Answer(
            title: title, questionId: questionId, id: BoxAnswer.currentAnswer));
  }

  Future<void> clear({required Box<Answer> box}) async {
    _titleController.text = '';
    updateCurrentAnswer(
      box: box,
      title: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    QuestionsModel questionsModel = Provider.of<QuestionsModel>(context);
    var _answerBox = Hive.box<Answer>(HiveBoxes.answers);

    // loading state if its exists
    if (_titleController.text.isEmpty) {
      var _answer = _answerBox.get(BoxAnswer.currentAnswer);
      _titleController.text = _answer?.title ?? '';
      if (_answer != null) {
        setState(() {
          var questionIndex = questionsModel.getIndexById(_answer.questionId);
          _questionsScrollController.jumpTo(questionIndex.toDouble());
          questionId = _answer.questionId;
        });
      }
    }
    return Material(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
              child: Row(children: [
                Expanded(
                    child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: questionsModel.length,
                  controller: _questionsScrollController,
                  itemBuilder: (context, index) => Container(
                      width: 120.0,
                      child: ElevatedButton(onPressed: () {
                        setState(() {
                          questionId =
                              questionsModel.questions.elementAt(index).id;
                        });
                      }, child: Consumer<LocaleModel>(
                          builder: (context, locale, child) {
                        return Text(questionsModel.questions
                                .elementAt(index)
                                .title
                                .getProp(locale.currentNamedLocale.name) ??
                            '');
                      }))),
                )),
                ShareButton(
                  project: widget.project,
                ),
              ]),
            ),
            SizedBox(
              height: 5,
            ),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  minLines: 1,
                  maxLines: 7,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) async {
                    await updateCurrentAnswer(box: _answerBox, title: text);
                  },
                  decoration: InputDecoration(
                      // labelStyle: TextStyle(color: Colors.white),
                      // fillColor: ThemeColors.lightAccent,
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //     color: ThemeColors.lightAccent ?? Colors.white,
                      //   ),
                      // ),
                      // border: OutlineInputBorder(
                      //     borderSide: BorderSide(
                      //         color: ThemeColors.lightAccent ?? Colors.white)),
                      labelText: AppLocalizations.of(context)?.answer),
                  cursorColor: Theme.of(context).accentColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: IconButton(
                  onPressed: () async {
                    var answers = widget.project.answers ??
                        HiveList(_answerBox, objects: []);
                    var newAnswer = Answer(
                        title: _titleController.text,
                        questionId: questionId,
                        id: uuid.v1());
                    _answerBox.put(newAnswer.id, newAnswer);
                    answers.add(newAnswer);
                    // FIXME: investiagte does project needs to be updtaed in box?

                    widget.project.answers = answers;
                    await clear(box: _answerBox);
                  },
                  icon: Icon(Icons.send),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
