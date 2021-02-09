import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:last_answer/abstract/Project.dart';
import 'package:last_answer/models/StorageMixin.dart';

class ProjectsModelConsts {
  static final String projects = 'projects';
  static final String selectedProject = 'selectedProject';
  static Project emptyProject = Project(id: 0, title: '');
}

class ProjectsModel extends ChangeNotifier with StorageMixin {
  Project selected = ProjectsModelConsts.emptyProject;
  final Map<int, Project> _projects = {};
  List<Project> get projectsList => _projects.values.toList();
  UnmodifiableListView<Project> get projects =>
      UnmodifiableListView(projectsList);
  Future<void> ini() async {
    print({'projects ini'});
    String projectsEncoded =
        await (await storage).getString(ProjectsModelConsts.projects);
    if (projects.isNotEmpty) fromJson(jsonDecode(projectsEncoded));

    String _selectedProjectEncoded =
        await (await storage).getString(ProjectsModelConsts.selectedProject);
    if (_selectedProjectEncoded.isNotEmpty)
      selected = Project.fromJson(jsonDecode(_selectedProjectEncoded));

    notifyListeners();
  }

  toJson() => projectsList.map((answer) => answer.toJson()).toList();

  fromJson(List answers) => answers.forEach((answer) {
        Project newAnswer = Project.fromJson(answer);
        _projects.putIfAbsent(newAnswer.id, () => newAnswer);
      });
}
