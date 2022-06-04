part of pack_settings;

ServerNoteSyncService createServerNoteSyncService(
  final BuildContext context,
) =>
    ServerNoteSyncService(
      api: context.read<ProjectsApi>(),
      usersNotifier: context.read(),
    );

class ServerNoteSyncService
    extends ServerSyncServiceImpl<NoteProject, NoteProjectModel> {
  ServerNoteSyncService({
    required final super.api,
    required this.usersNotifier,
  });
  final UsersNotifier usersNotifier;
  @override
  Future<void> onCreateFromOther(
    final Iterable<NoteProject> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
