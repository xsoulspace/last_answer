import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:last_answer/abstract/Project.dart';

class QuestionsAnswers extends StatelessWidget {
  final Project project;
  QuestionsAnswers({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        title: Hero(
            tag: 'title',
            child: Material(color: Colors.transparent, child: Text('hello'))),
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
                color: Colors.white,
              ))
        ],
      )),
    );
  }
}
