part of notifiers;

@immutable
class BasicProjectsService {
  const BasicProjectsService({
    required final this.ideas,
    required final this.notes,
    required final this.stories,
  });
  final Map<ProjectId, IdeaProject> ideas;
  final Map<ProjectId, NoteProject> notes;
  final Map<ProjectId, StoryProject> stories;
}
