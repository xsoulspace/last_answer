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
  Future<void> saveChanges({
    required final InstanceUpdaterDto<T, TOther> diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}

abstract class BasicProjectInstanceUpdater<T extends BasicProject,
    TOther extends BasicProjectModel> extends InstanceUpdater<T, TOther> {
  BasicProjectInstanceUpdater({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;
  UpdatableInstanceDiff<T, TOther> updateFolder({
    required final T original,
    required final TOther other,
  }) {
    bool otherWasUpdated = false;
    bool originalWasUpdated = false;
    TOther effectiveOther = other;
    if (original.folder?.id != other.folderId) {
      InstanceUpdatePolicy folderUpdatePolicy =
          InstanceUpdatePolicy.useClientVersion;
      if (original.folder == null) {
        folderUpdatePolicy = InstanceUpdatePolicy.useServerVersion;
      }
      switch (folderUpdatePolicy) {
        case InstanceUpdatePolicy.useClientVersion:
          effectiveOther = effectiveOther.copyWith(
            folderId: original.folder!.id,
          ) as TOther;
          otherWasUpdated = true;
          break;
        case InstanceUpdatePolicy.useServerVersion:
          final folder = foldersNotifier.state[other.folderId];
          folder?.addProject(original);
          originalWasUpdated = true;
          break;
      }
    }

    return UpdatableInstanceDiff(
      original: original,
      other: effectiveOther,
      originalWasUpdated: originalWasUpdated,
      otherWasUpdated: otherWasUpdated,
    );
  }
}
