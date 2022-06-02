part of pack_settings;

class ClientInstancesSyncServiceI<T extends HiveObjectWithId,
        TOther extends HasId> extends InstancesSyncServiceI<T, TOther>
    with
        // ignore: prefer_mixin
        InstancesSyncServiceApplier<T, TOther> {}

class HiveClientSyncServiceImpl<T extends HiveObjectWithId,
    TOther extends HasId> extends ClientInstancesSyncServiceI<T, TOther> {
  HiveClientSyncServiceImpl({
    required this.context,
  });
  final BuildContext context;
  @override
  Future<void> onUpdate(
    final Iterable<T> elements,
  ) async {
    await Future.wait(
      elements.map(
        (final el) => el.save(),
      ),
    );
  }

  @override
  Future<void> onDelete(
    final Iterable<T> elements,
  ) async {
    await Future.wait(
      elements.map(
        (final el) => el.deleteWithRelatives(context: context),
      ),
    );
  }

  @override
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<T, TOther> dto,
  }) async {
    await onCreateFromOther(dto.originalUpdates.toCreateFromOther);
    await onUpdate(dto.originalUpdates.toUpdate);
    await onDelete(dto.originalUpdates.toDelete);
  }
}
