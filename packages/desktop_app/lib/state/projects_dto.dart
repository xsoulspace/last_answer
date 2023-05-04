import 'package:flutter/cupertino.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';

@immutable
class BasicProjectsDto {
  const BasicProjectsDto({
    required this.ideas,
    required this.notes,
    required this.stories,
  });
  final Map<ProjectId, IdeaProject> ideas;
  final Map<ProjectId, NoteProject> notes;
  final Map<ProjectId, StoryProject> stories;
}
