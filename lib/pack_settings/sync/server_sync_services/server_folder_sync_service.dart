part of pack_settings;

class ServerFolderSyncService
    extends ServerSyncServiceImpl<ProjectFolder, ProjectFolderModel> {
  ServerFolderSyncService({
    required final super.api,
    required this.user,
  });
  final UserModel user;
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolder> elements,
  ) async {
    final models = elements.map((final e) => e.toModel(user: user));
    await onUpdate(models);
  }
}
