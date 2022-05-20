part of pack_settings;

class InstanceUpdater<T extends DeletableWithId, TOther extends HasId>
    implements RemotelyUpdatable<T, TOther> {
  InstanceUpdater({
    required this.list,
    required this.clientSyncService,
    required this.serverSyncService,
    this.policy = InstanceUpdatePolicy.useClientVersion,
  });
  final Iterable<T> list;
  final InstanceUpdatePolicy policy;
  final InstancesSyncService<T> clientSyncService;
  final InstancesSyncService<TOther> serverSyncService;

  @mustCallSuper
  Future<InstanceUpdaterDto<T, TOther>> updateByOther(
    final Iterable<TOther> otherList,
  ) async {
    final effectiveDiff = compareConsistency(otherList);
    return compareContent(diff: effectiveDiff);
  }

  /// Compares the elements of the lists, returns
  /// the new ones with deleted
  @mustCallSuper
  InstanceUpdaterDto<T, TOther> compareConsistency(
    final Iterable<TOther> otherList,
  ) {
    /// Generate other Map
    final otherMap = listWithIdToMap(otherList);

    final instancesToDeleteForOther = <TOther>[];
    final instancesToCreateForOther = <T>[];
    final instancesToCheckForOther = <InstanceId, InstanceDiff<T, TOther>>{};

    /// find differnces with [otherList] - online (server side)
    for (final el in list) {
      if (el.isToDelete) {
        final other = otherMap[el.id];
        if (other != null) {
          instancesToDeleteForOther.add(other);
          otherMap.remove(el.id);
        }
      } else {
        final other = otherMap[el.id];
        final isExists = other != null;
        if (isExists) {
          instancesToCheckForOther[el.id] =
              InstanceDiff(original: el, other: other);
        } else {
          instancesToCreateForOther.add(el);
        }
      }
    }

    final instancesToCreateForList = <TOther>[];

    /// find differnces with [list] - offline (client side)
    for (final el in otherMap.values) {
      final isNotExists = !instancesToCheckForOther.containsKey(el.id);
      if (isNotExists) {
        instancesToCreateForList.add(el);
      }
    }

    return InstanceUpdaterDto<T, TOther>(
      instancesToCheck: instancesToCheckForOther,
      originalUpdates: InstancesUpdatesDto(
        toCreateFromOther: instancesToCreateForList,
      ),
      otherUpdates: InstancesUpdatesDto(
        toCreateFromOther: instancesToCreateForOther,
        toDelete: instancesToDeleteForOther,
      ),
    );
  }

  Future<InstanceUpdaterDto<T, TOther>> compareContent({
    required final InstanceUpdaterDto<T, TOther> diff,
  }) async {
    // TODO(arenukvern): description
    throw UnimplementedError();
  }

  @override
  Future<void> saveChanges(
      {required final InstanceUpdaterDto<T, TOther> diff}) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
