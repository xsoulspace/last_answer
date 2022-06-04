part of pack_settings;

class ClientIdeaSyncService extends HiveClientSyncServiceImpl<IdeaProject,
    IdeaProjectModel, IdeaProjectsNotifier> {
  ClientIdeaSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectModel> elements,
  ) async {
    final ideasNotifier = context.read<IdeaProjectsNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final idea = await IdeaProject.fromModel(
          model: model,
          context: context,
        );
        ideasNotifier.put(key: idea.id, value: idea);
      }),
    );
  }
}
