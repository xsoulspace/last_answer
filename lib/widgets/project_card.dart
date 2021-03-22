import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/abstract/Project.dart';
import 'package:lastanswer/screens/questions_answers.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  ProjectCard({required this.project});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
              fullscreenDialog: true,
              reverseTransitionDuration: Duration(milliseconds: 250),
              transitionDuration: Duration(milliseconds: 350),
              transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) {
                var begin = Offset(0, 1.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: Curves.easeInOutSine));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return QuestionsAnswers(project: project);
              }));
        },
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Hero(
                              tag: 'title${project.id}',
                              child: Material(
                                  color: Colors.transparent,
                                  child: Text(project.title))),
                        ),
                        Hero(
                            tag: 'check${project.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Checkbox(
                                  value: project.isCompleted,
                                  onChanged: (bool? value) async {
                                    project.isCompleted = value ?? false;
                                    await project.save();
                                  }),
                            ))
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
