import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/Project.dart';
import 'package:lastanswer/widgets/answer_card.dart';
import 'package:lastanswer/widgets/new_answer_field.dart';

class QuestionsAnswers extends StatefulWidget {
  final Project project;
  QuestionsAnswers({required this.project});
  @override
  _QuestionsAnswersState createState() => _QuestionsAnswersState();
}

class _QuestionsAnswersState extends State<QuestionsAnswers> {
  TextEditingController _titleEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = widget.project.title;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        leading: IconButton(
            color: Theme.of(context).textTheme.headline6?.color,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
        title: Hero(
            tag: 'title${widget.project.id}',
            child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _titleEditingController,
                  onChanged: (String newText) async {
                    var project = widget.project;
                    project.title = newText;
                    await project.save();
                  },
                ))),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Hero(
                tag: 'check${widget.project.id}',
                child: Material(
                    color: Colors.transparent,
                    child: ValueListenableBuilder(
                      builder: (BuildContext _, Box<Project> box, Widget? __) {
                        return Checkbox(
                            value: widget.project.isCompleted,
                            onChanged: (bool? value) async {
                              var project = widget.project;
                              project.isCompleted = value ?? false;
                              await project.save();
                            });
                      },
                      valueListenable:
                          Hive.box<Project>(HiveBoxes.projects).listenable(),
                    ))),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    child: ValueListenableBuilder(
                  valueListenable:
                      Hive.box<Project>(HiveBoxes.projects).listenable(),
                  builder: (BuildContext _, Box<Project> __, Widget? child) {
                    var answers = widget.project.answers ?? [];
                    answers.sort((a, b) => a.created.compareTo(b.created));
                    var reversedAnswers = answers.reversed;
                    return ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                              height: 1,
                              child: Divider(
                                height: 0.5,
                                thickness: 0.15,
                              ),
                            ),
                        addSemanticIndexes: true,
                        reverse: true,
                        itemCount: reversedAnswers.length,
                        itemBuilder: (BuildContext context, int index) {
                          var answer = reversedAnswers.elementAt(index);
                          if (answer.id == BoxAnswer.currentAnswer)
                            return Container(
                              key: Key(index.toString()),
                            );
                          return AnswerCard(
                            key: Key(answer.id),
                            index: index,
                            answer: answer,
                            onDismissed: () async {
                              await answer.delete();
                              setState(() {});
                            },
                            confirmDelete: () async {
                              return await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)
                                              ?.areYouSure ??
                                          ''),
                                      content: Text(
                                          " '${answer.title}' ${AppLocalizations.of(context)?.answerWillBeLost}"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.cancel ??
                                                '',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                      ?.delete ??
                                                  '',
                                              style: TextStyle(
                                                  color: Colors.red[800]),
                                            )),
                                      ],
                                    );
                                  });
                            },
                          );
                        });
                  },
                )),
                SizedBox(
                  height: 2,
                ),
                NewAnswerField(project: widget.project)
              ],
            )
          ],
        )),
      ),
    );
  }
}
