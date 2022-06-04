part of pack_settings;

class ClientFolderSyncService extends HiveClientSyncServiceImpl<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  ClientFolderSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolderModel> elements,
  ) async {
    final foldersNotifier = context.read<ProjectFoldersNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final folder = await ProjectFolder.fromModel(model);
        foldersNotifier.put(key: folder.id, value: folder);
      }),
    );
  }
}
