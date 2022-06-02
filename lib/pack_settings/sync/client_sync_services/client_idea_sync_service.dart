part of pack_settings;

class ClientIdeaSyncService
    extends HiveClientSyncServiceImpl<IdeaProject, IdeaProjectModel> {
  ClientIdeaSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectModel> elements,
  ) async {
    final ideasNotifier = context.read<IdeaProjectsNotifier>();
    for (final model in elements) {
      final idea = await IdeaProject.fromModel(
        model: model,
        context: context,
      );
      ideasNotifier.put(key: idea.id, value: idea);
    }
  }
}
