part of pack_settings;

ServerFolderSyncService createServerFolderSyncService(
  final BuildContext context,
) =>
    ServerFolderSyncService(
      api: context.read<FoldersApi>(),
      usersNotifier: context.read(),
    );

class ServerFolderSyncService
    extends ServerSyncServiceImpl<ProjectFolder, ProjectFolderModel> {
  ServerFolderSyncService({
    required final super.api,
    required this.usersNotifier,
  });
  final UsersNotifier usersNotifier;
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolder> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
