import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/hive_boxes_ids.dart';
import 'package:lastanswer/abstract/project_folder.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

part 'story_project.g.dart';

// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  StoryProject({
    required final super.id,
    required final super.title,
    required final super.createdAt,
    required final this.folder,
    this.isToDelete = defaultProjectIsDeleted,
    final DateTime? updatedAt,
    final super.isCompleted = defaultProjectIsCompleted,
  }) : super(
          updatedAt: updatedAt ?? createdAt,
          folder: folder,
          type: ProjectType.story,
        );

  @override
  @HiveField(projectLatestFieldHiveId + 1)
  ProjectFolder? folder;

  @override
  @HiveField(projectLatestFieldHiveId + 2)
  bool isToDelete;

  @override
  BasicProjectModel toModel({required final UserModel user}) {
    // TODO(arenukvern): implement toModel
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWithRelatives({required final BuildContext context}) {
    // TODO: implement deleteWithRelatives
    throw UnimplementedError();
  }
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
// class MockStoryProject extends Mock implements StoryProject {}
