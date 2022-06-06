part of pack_settings;

ServerFolderSubscriber createFolderSubscriberNotifier(
  final BuildContext context,
) =>
    ServerFolderSubscriber(
      api: context.read<FoldersApi>(),
      updater: context.read<FolderUpdater>(),
    );

class ServerFolderSubscriber extends SingleInstanceSubscriber<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  ServerFolderSubscriber({
    required final super.updater,
    required final super.api,
  });
}
