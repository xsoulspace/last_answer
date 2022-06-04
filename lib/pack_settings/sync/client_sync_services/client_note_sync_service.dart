part of pack_settings;

class ClientNoteSyncService extends HiveClientSyncServiceImpl<NoteProject,
    NoteProjectModel, NoteProjectsNotifier> {
  ClientNoteSyncService({required final super.context});

  factory ClientNoteSyncService.of(final BuildContext context) =>
      ClientNoteSyncService(context: context);

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
