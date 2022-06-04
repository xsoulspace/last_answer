part of pack_settings;

FolderSubscriber createFolderSubscriber(final BuildContext context) =>
    FolderSubscriber(
      api: context.read<FoldersApi>(),
      updater: context.read<FolderUpdater>(),
    );

class FolderSubscriber extends SingleInstanceSubscriber<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  FolderSubscriber({required final super.updater, required final super.api});
}
