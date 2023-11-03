import 'package:flutter/cupertino.dart';

import '../datasources/datasources.dart';

@immutable
class BasicProjectsService {
  const BasicProjectsService({
    required this.ideas,
    required this.notes,
    required this.stories,
  });
  final Map<IdeaProjectId, IdeaProject> ideas;
  final Map<NoteProjectId, NoteProject> notes;
  final Map<StoryProjectId, StoryProject> stories;
}
