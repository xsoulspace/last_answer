part of pack_settings;

class ClientFolderSyncService
    extends HiveClientSyncServiceImpl<ProjectFolder, ProjectFolderModel> {
  ClientFolderSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolderModel> elements,
  ) async {
    final foldersNotifier = context.read<ProjectFoldersNotifier>();
    for (final model in elements) {
      final folder = await ProjectFolder.fromModel(model);
      foldersNotifier.put(key: folder.id, value: folder);
    }
  }

  @override
  Future<void> onDelete(final Iterable<ProjectFolder> elements) async {
    await Future.wait(
      elements
          .map((final folder) => folder.deleteWithRelatives(context: context)),
    );
  }
}
