import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/widgets/new_answer_field.dart';

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
    var size = MediaQuery.of(context).size;
    _titleEditingController.text = widget.project.title;
    var _projectBox = Hive.box<Project>(HiveBoxes.projects);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        leading: IconButton(
            color: Theme.of(context).textTheme.bodyText2?.color,
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
                    await _projectBox.put(project.id, project);
                  },
                ))),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Hero(
                tag: 'check${widget.project.id}',
                child: Material(
                    color: Colors.transparent,
                    child: Checkbox(
                        value: widget.project.isCompleted,
                        onChanged: (bool? value) async {
                          var project = widget.project;
                          project.isCompleted = value ?? false;
                          await _projectBox.put(project.id, project);
                        }))),
          )
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Hero(
              tag: 'back${widget.project.id}',
              child: Container(
                color: Theme.of(context).canvasColor,
              )),
          SizedBox(
            height: 300,
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                      height: 2,
                    ),
                addSemanticIndexes: true,
                reverse: true,
                itemCount: widget.project.answers?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  var answer = widget.project.answers?.elementAt(index);
                  if (answer == null || answer.id == BoxAnswer.currentAnswer)
                    return Container();
                  return Text(answer.title);
                  // return AnswerCard(index: index, answer: answer);
                }),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NewAnswerField(project: widget.project))
        ],
      )),
    );
  }
}
