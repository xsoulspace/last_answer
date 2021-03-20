import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:last_answer/abstract/Project.dart';

class QuestionsAnswers extends StatefulWidget {
  final Project project;
  QuestionsAnswers({required this.project});
  @override
  _QuestionsAnswersState createState() => _QuestionsAnswersState();
}

class _QuestionsAnswersState extends State<QuestionsAnswers> {
  TextEditingController _titleEditingController =
      TextEditingController(text: 'hello');

  @override
  Widget build(BuildContext context) {
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
            tag: 'title',
            child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _titleEditingController,
                ))),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Hero(
                tag: 'check',
                child: Material(
                    color: Colors.transparent,
                    child: Checkbox(value: true, onChanged: (bool? value) {}))),
          )
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Hero(
              tag: 'back',
              child: Container(
                color: Theme.of(context).canvasColor,
              ))
        ],
      )),
    );
  }
}
