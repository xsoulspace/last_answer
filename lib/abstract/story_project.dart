import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/basic_project.dart';

import 'hive_boxes.dart';

part 'store_project.g.dart';

@HiveType(typeId: HiveBoxes.projectId)
class StoryProject extends BasicProject {
  StoryProject({
    required final String id,
    required final String title,
    required final DateTime created,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
        );
}
