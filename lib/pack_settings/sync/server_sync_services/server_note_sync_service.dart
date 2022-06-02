part of pack_settings;

class ServerNoteSyncService
    extends ServerSyncServiceImpl<NoteProject, NoteProjectModel> {
  ServerNoteSyncService({
    required final super.api,
    required this.user,
  });
  final UserModel user;
  @override
  Future<void> onCreateFromOther(
    final Iterable<NoteProject> elements,
  ) async {
    final models = elements.map((final e) => e.toModel(user: user));
    await onUpdate(models);
  }
}
