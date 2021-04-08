import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/Project.dart';
import 'package:uuid/uuid.dart';

class NewProjectField extends StatefulWidget {
  @override
  _NewProjectFieldState createState() => _NewProjectFieldState();
}

class _NewProjectFieldState extends State<NewProjectField> {
  final TextEditingController _titleController = TextEditingController();
  final uuid = Uuid();
  Future<void> updateCurrentProject({required Box<Project> box}) async {
    await box.put(
        BoxProject.currentProject,
        Project(
            created: DateTime.now(),
            id: BoxProject.currentProject,
            title: _titleController.text));
  }

  Future<void> createProject({required Box<Project> projectBox}) async {
    if (_titleController.text
        .replaceAll(RegExp(r' '), "")
        .replaceAll("\n", "")
        .isEmpty) return;
    var newUuid = uuid.v1();
    var newProject = Project(
        created: DateTime.now(), id: newUuid, title: _titleController.text);
    _titleController.clear();
    await projectBox.put(newUuid, newProject);
    await updateCurrentProject(box: projectBox);
  }

  var focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    var _projectBox = Hive.box<Project>(HiveBoxes.projects);
    if (_titleController.text.isEmpty) {
      var project = _projectBox.get(BoxProject.currentProject);
      if (project != null) _titleController.text = project.title;
    }
    return Row(children: [
      Expanded(
        child: RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                !event.isShiftPressed) {
              createProject(projectBox: _projectBox);
            }
          },
          child: TextFormField(
            controller: _titleController,
            minLines: 1,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            onChanged: (text) async {
              await updateCurrentProject(box: _projectBox);
            },
            decoration: InputDecoration(
                // labelStyle: TextStyle(color: Colors.white),
                // fillColor: ThemeColors.lightAccent,
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: ThemeColors.lightAccent ?? Colors.white,
                //   ),
                // ),
                // border: OutlineInputBorder(
                //     borderSide: BorderSide(
                //         color: ThemeColors.lightAccent ?? Colors.white)),
                labelText: AppLocalizations.of(context)?.idea),
            cursorColor: Theme.of(context).accentColor,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 10),
        child: IconButton(
          onPressed: () async => await createProject(projectBox: _projectBox),
          icon: Icon(
            Icons.arrow_circle_up,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    ]);
  }
}
