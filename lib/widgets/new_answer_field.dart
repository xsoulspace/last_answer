import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/Answer.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/abstract/Question.dart';
import 'package:last_answer/models/questions_model.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewAnswerField extends StatefulWidget {
  final Project project;
  NewAnswerField({required this.project});
  @override
  _NewAnswerFieldState createState() => _NewAnswerFieldState();
}

class _NewAnswerFieldState extends State<NewAnswerField> {
  Question question = QuestionsModelConsts.questions[5];

  Future<void> updateCurrentAnswer(
      {required Box<Answer> box, required String title}) async {
    await box.put(BoxAnswer.currentAnswer,
        Answer(title: title, question: question, id: 'current answer'));
  }

  Future<void> clear({required Box<Answer> box}) async {
    _titleController.text = '';
    updateCurrentAnswer(
      box: box,
      title: '',
    );
  }

  var uuid = Uuid();

  final TextEditingController _titleController = TextEditingController();
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
          question = _answer.question;
        });
      }
    }
    return Column(
      children: <Widget>[
        SizedBox(height: 1),
        Divider(),
        SizedBox(height: 10),
        Container(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questionsModel.length,
              itemBuilder: (context, index) => Container(
                  width: 120.0,
                  child: ElevatedButton(onPressed: () {
                    setState(() {
                      question = questionsModel.questions[index];
                    });
                  }, child:
                      Consumer<LocaleModel>(builder: (context, locale, child) {
                    return Text(questionsModel.questions
                            .elementAt(index)
                            .title
                            .getProp(locale.currentNamedLocale.name) ??
                        '');
                  }))),
            )),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Consumer<LocaleModel>(builder: (context, locale, child) {
            return Text(
                question.title.getProp(locale.currentNamedLocale.name) ?? '');
          }),
        ),
        SizedBox(
          height: 20,
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
                var answers =
                    widget.project.answers ?? HiveList(_answerBox, objects: []);

                answers.add(Answer(
                    title: _titleController.text,
                    question: question,
                    id: uuid.v1()));

                widget.project.answers = answers;
                // FIXME: investiagte does project needs to be updtaed in box?
                await clear(box: _answerBox);
              },
              icon: Icon(Icons.send),
            ),
          ),
        ])
      ],
    );
  }
}
