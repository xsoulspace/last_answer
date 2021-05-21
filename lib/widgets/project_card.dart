import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lastanswer/abstract/project.dart';
import 'package:lastanswer/screens/questions_answers.dart';
import 'package:lastanswer/widgets/card_dissmisible.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  ProjectCard({required this.project});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 6),
      clipBehavior: Clip.antiAlias,
      child: CardDissmisible(
        key: Key(project.id),
        confirmDismiss: (direction) async {
          if (direction.index != 3) return false;
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)?.areYouSure ?? ''),
                content: Text(
                    " '${project.title}' ${AppLocalizations.of(context)?.titleWith} ${project.answers?.length ?? 0} ${AppLocalizations.of(context)?.projectWillBeLost}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      AppLocalizations.of(context)?.cancel ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        AppLocalizations.of(context)?.delete ?? '',
                        style: TextStyle(color: Colors.red[800]),
                      )),
                ],
              );
            },
          );
        },
        onDismissed: (direction) async {
          await project.answers?.deleteAllFromHive();
          await project.delete();
        },
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
      ),
    );
  }
}
