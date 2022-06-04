part of pack_settings;

class ServerInstancesSyncServiceI<T extends HiveObjectWithId,
        TOther extends HasId> extends InstancesSyncServiceI<TOther, T>
    with
        // ignore: prefer_mixin
        InstancesSyncServiceApplier<T, TOther> {
  Future<Iterable<TOther>> getAll() async => throw UnimplementedError();
}

class ServerSyncServiceImpl<T extends HiveObjectWithId, TOther extends HasId>
    extends ServerInstancesSyncServiceI<T, TOther> {
  ServerSyncServiceImpl({
    required this.api,
  });
  final AbstractApi<TOther> api;

  @override
  Future<Iterable<TOther>> getAll() async => api.getAll();

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
