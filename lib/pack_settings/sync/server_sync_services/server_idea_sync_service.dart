part of pack_settings;

class ServerIdeaSyncService
    extends ServerSyncServiceImpl<IdeaProject, IdeaProjectModel> {
  ServerIdeaSyncService({
    required final super.api,
    required this.user,
  });
  final UserModel user;
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProject> elements,
  ) async {
    final models = elements.map((final e) => e.toModel(user: user));
    await onUpdate(models);
  }
}
