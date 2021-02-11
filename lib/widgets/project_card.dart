import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/screens/questions_answers.dart';

class ProjectCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Hero(
              tag: 'back',
              child: Container(color: Theme.of(context).canvasColor),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Hero(
                          tag: 'title',
                          child: Material(
                              color: Colors.transparent, child: Text('hello'))),
                      Hero(
                          tag: 'check',
                          child: Material(
                            color: Colors.transparent,
                            child: Checkbox(
                                value: true,
                                onChanged: (bool? value) {
                                  print(value);
                                }),
                          ))
                    ],
                  )),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            fullscreenDialog: true,
            transitionDuration: Duration(milliseconds: 150),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return QuestionsAnswers(project: Project(id: 0, title: ''));
            }));
      },
    );
  }
}
