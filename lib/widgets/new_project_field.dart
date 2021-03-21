import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:last_answer/abstract/HiveBoxes.dart';
import 'package:last_answer/abstract/Project.dart';
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

  @override
  Widget build(BuildContext context) {
    var _projectBox = Hive.box<Project>(HiveBoxes.projects);
    if (_titleController.text.isEmpty) {
      var project = _projectBox.get(BoxProject.currentProject);
      if (project != null) _titleController.text = project.title;
    }
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: _titleController,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          onChanged: (text) async {
            await updateCurrentProject(box: _projectBox);
          },
          // decoration: InputDecoration(
          //     // labelStyle: TextStyle(color: Colors.white),
          //     // fillColor: ThemeColors.lightAccent,
          //     // focusedBorder: OutlineInputBorder(
          //     //   borderSide: BorderSide(
          //     //     color: ThemeColors.lightAccent ?? Colors.white,
          //     //   ),
          //     // ),
          //     // border: OutlineInputBorder(
          //     //     borderSide: BorderSide(
          //     //         color: ThemeColors.lightAccent ?? Colors.white)),
          //     labelText: AppLocalizations.of(context)?.answer),
          cursorColor: Theme.of(context).accentColor,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 10),
        child: IconButton(
          onPressed: () async {
            if (_titleController.text.isEmpty) return;
            var newUuid = uuid.v1();
            await _projectBox.put(
                newUuid,
                Project(
                    created: DateTime.now(),
                    id: newUuid,
                    title: _titleController.text));
            _titleController.clear();
            await updateCurrentProject(box: _projectBox);
          },
          icon: Icon(Icons.send),
        ),
      ),
    ]);
  }
}
