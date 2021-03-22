import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/Answer.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/Project.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/widgets/share_button.dart';
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
  late ScrollController _questionsScrollController;
  @override
  initState() {
    _questionsScrollController = ScrollController();
    super.initState();
  }

  Future<void> updateCurrentAnswer(
      {required Box<Answer> box, required String title}) async {
    await box.put(
        BoxAnswer.currentAnswer,
        Answer(
            created: DateTime.now(),
            title: title,
            questionId: questionId,
            id: BoxAnswer.currentAnswer));
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
          if (_questionsScrollController.hasClients) {
            _questionsScrollController.jumpTo(questionIndex.toDouble());
          }
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
              height: 2,
            ),
            SizedBox(
              height: 50,
              child: Row(children: [
                Expanded(
                    child: ListView.separated(
                        separatorBuilder: (BuildContext _, int index) {
                          return SizedBox(
                            width: 10,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                        itemCount: questionsModel.length,
                        controller: _questionsScrollController,
                        itemBuilder: (BuildContext _, int index) {
                          var question =
                              questionsModel.questions.elementAt(index);
                          var text = Consumer<LocaleModel>(
                              builder: (context, locale, child) {
                            return Text(question.title.getProp(
                                    locale.currentNamedLocale.localeCode) ??
                                '');
                          });
                          if (question.id == questionId)
                            return TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(horizontal: 28)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.05))),
                              onPressed: () {},
                              child: text,
                            );
                          return TextButton(
                            onPressed: () {
                              questionId = question.id;
                              updateCurrentAnswer(
                                box: _answerBox,
                                title: _titleController.text,
                              );
                              setState(() {
                                _questionsScrollController
                                    .jumpTo(index.toDouble());
                              });
                            },
                            child: text,
                          );
                        })),
                SizedBox(
                  width: 8,
                ),
                ShareButton(
                  project: widget.project,
                ),
              ]),
            ),
            SizedBox(
              height: 2,
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
                        id: uuid.v1(),
                        created: DateTime.now());
                    await _answerBox.put(newAnswer.id, newAnswer);
                    answers.add(newAnswer);
                    // FIXME: investiagte does project needs to be updtaed in box?

                    widget.project.answers = answers;
                    widget.project.save();
                    await clear(box: _answerBox);
                  },
                  icon: Icon(
                    Icons.arrow_circle_up,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
