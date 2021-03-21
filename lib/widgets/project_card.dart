import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/screens/questions_answers.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  ProjectCard({required this.project});
  @override
  Widget build(BuildContext context) {
    var _projectBox = Hive.box<Project>(HiveBoxes.projects);
    return GestureDetector(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              Hero(
                tag: 'back${project.id}',
                child: Container(color: Theme.of(context).canvasColor),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                            tag: 'title${project.id}',
                            child: Material(
                                color: Colors.transparent,
                                child: Text(project.title))),
                        Hero(
                            tag: 'check${project.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Checkbox(
                                  value: project.isCompleted,
                                  onChanged: (bool? value) async {
                                    project.isCompleted = value ?? false;
                                    await _projectBox.put(project.id, project);
                                  }),
                            ))
                      ],
                    )),
              ),
            ],
          ),
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
