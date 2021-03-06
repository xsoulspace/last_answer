import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/Project.dart';
import 'package:lastanswer/screens/settings.dart';
import 'package:lastanswer/widgets/new_project_field.dart';
import 'package:lastanswer/widgets/project_card.dart';

class HomeProjects extends StatelessWidget {
  HomeProjects({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _openSettings() {
      Navigator.of(context).push(PageRouteBuilder(
          fullscreenDialog: true,
          barrierColor: Colors.transparent,
          opaque: false,
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
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8,
                    sigmaY: 8,
                  ),
                  child: Container(
                      // color: Colors.white.withOpacity(0.08),
                      ),
                ),
                Settings()
              ],
            );
          }));
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Material(
              elevation: 1,
              // color: Theme.of(context).primaryColor,
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
                    builder: (BuildContext _, Box<Project> _projectBox,
                        Widget? widget) {
                      var projects = _projectBox.values.toList();
                      projects.sort((a, b) => a.created.compareTo(b.created));
                      var reversed = projects.reversed;

                      return ListView.builder(
                        reverse: true,
                        itemBuilder: (BuildContext _, int index) {
                          var _project = reversed.elementAt(index);

                          if (_project.id == BoxProject.currentProject)
                            return Container();
                          return ProjectCard(
                            project: _project,
                          );
                        },
                        itemCount: _projectBox.values.length,
                      );
                    })),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: NewProjectField(),
            )
          ],
        ),
      ),
    );
  }
}
