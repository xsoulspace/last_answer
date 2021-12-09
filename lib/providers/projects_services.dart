part of providers;

@immutable
class BasicProjectsService {
  const BasicProjectsService({
    required final this.ideas,
    required final this.notes,
    required final this.stories,
  });
  final Map<IdeaProjectId, IdeaProject> ideas;
  final Map<NoteProjectId, NoteProject> notes;
  final Map<StoryProjectId, StoryProject> stories;
}
