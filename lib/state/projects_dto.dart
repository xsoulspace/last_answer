import 'package:flutter/cupertino.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

@immutable
class BasicProjectsDto {
  const BasicProjectsDto({
    required final this.ideas,
    required final this.notes,
    required final this.stories,
  });
  final Map<ProjectId, IdeaProject> ideas;
  final Map<ProjectId, NoteProject> notes;
  final Map<ProjectId, StoryProject> stories;
}
