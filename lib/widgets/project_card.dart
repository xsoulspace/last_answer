import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/screens/questions_answers.dart';
import 'package:last_answer/widgets/answer_card.dart';
import 'package:last_answer/widgets/new_answer_field.dart';
import 'package:last_answer/widgets/share_button.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  ProjectCard({required this.project});
  @override
  Widget build(BuildContext context) {
    var _projectBox = Hive.box(HiveBoxes.projects);
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
                                  _projectBox.put(project.id, project);
                                }),
                          ))
                    ],
                  )),
            ),
            ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                      height: 2,
                    ),
                addSemanticIndexes: true,
                reverse: true,
                itemCount: project.answers?.length ?? 0,
                itemBuilder: (context, index) {
                  var answer = project.answers?.reversed.elementAt(index);
                  if (answer == null) return Container();
                  return AnswerCard(index: index, answer: answer);
                }),
            Positioned(
                bottom: 20,
                right: 29,
                child: ShareButton(
                  project: project,
                )),
            Positioned(bottom: 0, child: NewAnswerField(project: project))
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
              return QuestionsAnswers(project: project);
            }));
      },
    );
  }
}
