part of pack_settings;

ServerProjectsSyncService createServerProjectsSyncService(
  final BuildContext context,
) =>
    ServerProjectsSyncService(
      api: context.read<ProjectsApi>(),
      usersNotifier: context.read(),
    );

class ServerProjectsSyncService extends ServerInstancesSyncServiceI<
    BasicProject<BasicProjectModel>, BasicProjectModel> {
  ServerProjectsSyncService({
    required this.api,
    required this.usersNotifier,
  });
  final UsersNotifier usersNotifier;

  @override
  Future<void> upsert(
    final Iterable<BasicProject<BasicProjectModel>> list,
  ) async {
    final user = usersNotifier.currentUser.value;
    for (final el in list) {
      await api.upsert(el.toModel(user: user));
    }
  }

  @override
  Future<void> onCreateFromOther(
    final Iterable<BasicProject> elements,
  ) async {
    final models = elements.map(
      (final e) =>
          e.toModel(user: usersNotifier.currentUser.value) as BasicProjectModel,
    );
    await onUpdate(models);
  }

  final AbstractApi<BasicProjectModel> api;

  @override
  Future<Iterable<BasicProjectModel>> getAll() async => api.getAll();

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
