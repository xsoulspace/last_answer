part of pack_settings;

class InstancesSyncService<T extends HasId> {
  Future<void> onCreate(final Iterable<T> elements) async {}
  Future<void> onUpdate(final Iterable<T> elements) async {}
  Future<void> onDelete(final Iterable<T> elements) async {}
  Future<void> applyDiff() async {
    // await onCreate();
    // await onUpdate();
    // await onDelete();
  }
}

class HiveClientSyncService<T extends HiveObjectWithId>
    extends InstancesSyncService<T> {
  @override
  Future<void> onCreate(
    final Iterable<T> elements,
  ) async {}

  @override
  Future<void> onUpdate(
    final Iterable<T> elements,
  ) async {
    for (final el in elements) {
      await el.save();
    }
  }

  @override
  Future<void> onDelete(
    final Iterable<T> elements,
  ) async {
    for (final el in elements) {
      await el.delete();
    }
  }
}

class ServerSyncService<T extends HasId> extends InstancesSyncService<T> {
  ServerSyncService({
    required this.api,
  });
  final AbstractApi<T> api;
  @override
  Future<void> onCreate(
    final Iterable<T> elements,
  ) async {
    await api.upsertElements(elements);
  }

  @override
  Future<void> onUpdate(
    final Iterable<T> elements,
  ) async {
    await api.upsertElements(elements);
  }

  @override
  Future<void> onDelete(
    final Iterable<T> elements,
  ) async {
    for (final el in elements) {
      await api.delete(el);
    }
  }
}
