import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/screens/settings.dart';
import 'package:last_answer/widgets/new_project_field.dart';
import 'package:last_answer/widgets/project_card.dart';

class HomeProjects extends StatelessWidget {
  HomeProjects({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _openSettings() {
      Navigator.of(context).push(PageRouteBuilder(
          fullscreenDialog: true,
          transitionDuration: Duration(milliseconds: 250),
          reverseTransitionDuration: Duration(milliseconds: 250),
          barrierDismissible: true,
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
            return Settings();
          }));
    }

    return SafeArea(
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Hero(
                      tag: 'appBarBackground',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(color: Theme.of(context).canvasColor),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Hero(
                        tag: 'appBarMenuButton',
                        child: Material(
                          shape: CircleBorder(),
                          color: Colors.transparent,
                          child: IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                              onPressed: _openSettings),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
                child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<Project>(HiveBoxes.projects).listenable(),
              builder:
                  (BuildContext _, Box<Project> _projectBox, Widget? widget) =>
                      ListView.builder(
                reverse: true,
                itemBuilder: (BuildContext _, int index) {
                  var _project =
                      _projectBox.values.toList().reversed.elementAt(index);

                  if (_project.id == BoxProject.currentProject)
                    return Container();
                  return ProjectCard(
                    project: _project,
                  );
                },
                itemCount: _projectBox.values.length,
              ),
            )),
            NewProjectField()
          ],
        ),
      ),
    );
  }
}
