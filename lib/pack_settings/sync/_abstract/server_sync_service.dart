part of pack_settings;

class ServerInstancesSyncServiceI<T extends RemoteHiveObjectWithId<TOther>,
        TOther extends HasId> extends InstancesSyncServiceI<TOther, T>
    with
        // ignore: prefer_mixin
        InstancesSyncServiceApplier<T, TOther> {
  ServerInstancesSyncServiceI({
    required this.api,
    required this.usersNotifier,
  });
  final AbstractApi<TOther> api;
  final UsersNotifier usersNotifier;

  Future<Iterable<TOther>> getAll() async => api.getAll();

  Future<void> upsert(final Iterable<T> list) async {
    final user = usersNotifier.currentUser.value;
    for (final el in list) {
      await api.upsert(el.toModel(user: user));
    }
  }

  Future<void> delete(
    final Iterable<T> list,
  ) async {
    final user = usersNotifier.currentUser.value;
    for (final el in list) {
      await api.delete(el.toModel(user: user));
    }
  }
}

class ServerSyncServiceImpl<T extends RemoteHiveObjectWithId<TOther>,
    TOther extends HasId> extends ServerInstancesSyncServiceI<T, TOther> {
  ServerSyncServiceImpl({
    required final super.api,
    required final super.usersNotifier,
  });

  @override
  Future<void> onUpdate(
    final Iterable<TOther> elements,
  ) async {
    await api.upsertElements(elements);
  }

  @override
  Future<void> onDelete(
    final Iterable<TOther> elements,
  ) async {
    for (final el in elements) {
      await api.delete(el);
    }
  }

  @override
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<T, TOther> dto,
  }) async {
    await onCreateFromOther(dto.otherUpdates.toCreateFromOther);
    await onUpdate(dto.otherUpdates.toUpdate);
    await onDelete(dto.otherUpdates.toDelete);
  }
}
