part of pack_settings;

ServerProjectsSyncService createServerProjectsSyncService(
  final BuildContext context,
) =>
    ServerProjectsSyncService(
      api: context.read<ProjectsApi>(),
      usersNotifier: context.read(),
    );

class ServerProjectsSyncService
    extends ServerInstancesSyncServiceI<BasicProject, BasicProjectModel> {
  ServerProjectsSyncService({
    required final super.api,
    required final super.usersNotifier,
  });

  @override
  Future<void> onCreateFromOther(
    final Iterable<BasicProject> elements,
  ) async {
    final models = elements.map(
      (final e) => e.toModel(user: usersNotifier.currentUser.value),
    );
    await onUpdate(models);
  }

  @override
  Future<void> onUpdate(
    final Iterable<BasicProjectModel> elements,
  ) async {
    await api.upsertElements(elements);
  }

  @override
  Future<void> onDelete(
    final Iterable<BasicProjectModel> elements,
  ) async {
    for (final el in elements) {
      await api.delete(el);
    }
  }

  @override
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<BasicProject, BasicProjectModel> dto,
  }) async {
    await onCreateFromOther(dto.otherUpdates.toCreateFromOther);
    await onUpdate(dto.otherUpdates.toUpdate);
    await onDelete(dto.otherUpdates.toDelete);
  }
}
