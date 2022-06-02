part of pack_settings;

class ClientNoteSyncService
    extends HiveClientSyncServiceImpl<NoteProject, NoteProjectModel> {
  ClientNoteSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<NoteProjectModel> elements,
  ) async {
    final notesNotifier = context.read<NoteProjectsNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final idea = await NoteProject.fromModel(
          model: model,
          context: context,
        );
        notesNotifier.put(key: idea.id, value: idea);
      }),
    );
  }
}
