part of pack_settings;

class FolderSubscriber extends InstanceSubscriber<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  FolderSubscriber({required final super.updater, required final super.api});
}
