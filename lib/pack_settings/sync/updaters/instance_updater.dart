part of pack_settings;

class InstanceUpdater<TMutable extends DeletableWithId,
        TImmutableOther extends HasId>
    implements RemotelyUpdatable<TMutable, TImmutableOther> {
  InstanceUpdater({
    required this.list,
    required this.clientSyncService,
    required this.serverSyncService,
    this.policy = InstanceUpdatePolicy.useClientVersion,
  });
  final Iterable<TMutable> list;
  final InstanceUpdatePolicy policy;
  final InstancesSyncService<TMutable, TImmutableOther> clientSyncService;
  final InstancesSyncService<TMutable, TImmutableOther> serverSyncService;

  @mustCallSuper
  Future<void> updateByOther(
    final Iterable<TImmutableOther> otherList,
  ) async {
    InstanceUpdaterDto<TMutable, TImmutableOther> dto =
        compareConsistency(otherList);

    dto = await compareContent(dto: dto);

    await saveChanges(dto: dto);
  }

  /// Compares the elements of the lists, returns
  /// the new ones with deleted
  @mustCallSuper
  InstanceUpdaterDto<TMutable, TImmutableOther> compareConsistency(
    final Iterable<TImmutableOther> otherList,
  ) {
    /// Generate other Map
    final otherMap = listWithIdToMap(otherList);

    final instancesToDeleteForOther = <TImmutableOther>[];
    final instancesToCreateForOther = <TMutable>[];
    final instancesToCheckForOther =
        <InstanceId, InstanceDiff<TMutable, TImmutableOther>>{};

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

    final instancesToCreateForList = <TImmutableOther>[];

    /// find differnces with [list] - offline (client side)
    for (final el in otherMap.values) {
      final isNotExists = !instancesToCheckForOther.containsKey(el.id);
      if (isNotExists) {
        instancesToCreateForList.add(el);
      }
    }

    return InstanceUpdaterDto<TMutable, TImmutableOther>(
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

  /// Use [compareDiffContent] to create [compareContent] function
  Future<InstanceUpdaterDto<TMutable, TImmutableOther>> compareContent({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> dto,
  }) async {
    // TODO(arenukvern): unimplemented
    throw UnimplementedError();
  }

  Future<InstanceUpdaterDto<TMutable, TImmutableOther>> compareDiffContent({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> diff,
    required final OnCheckUpdater<TMutable, TImmutableOther> onCheck,
  }) async =>
      _compareDiffContent(
        diff: diff,
        updatables: [onCheck],
      );

  Future<InstanceUpdaterDto<TMutable, TImmutableOther>> _compareDiffContent({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> diff,
    required final List<OnCheckUpdater<TMutable, TImmutableOther>> updatables,
    final TImmutableOther Function(TMutable, TImmutableOther)? onUpdated,
  }) async {
    final otherUpdates = <TImmutableOther>[];
    final originalUpdates = <TMutable>[];

    for (final instanceDiff in diff.instancesToCheck.values) {
      final original = instanceDiff.original;
      TImmutableOther other = instanceDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

      for (final updateCallback in updatables) {
        final updateDiffResult = updateCallback(
          UpdatableInstanceDiff(
            original: original,
            other: other,
            originalWasUpdated: originalWasUpdated,
            otherWasUpdated: otherWasUpdated,
          ),
        );

        other = updateDiffResult.other;
        otherWasUpdated = updateDiffResult.otherWasUpdated;
        originalWasUpdated = updateDiffResult.originalWasUpdated;
      }

      if (otherWasUpdated || originalWasUpdated) {
        onUpdated?.call(original, other);
        otherUpdates.add(other);
        originalUpdates.add(original);
      }
    }

    return diff.copyWith(
      otherUpdates: diff.otherUpdates.copyWith(
        toUpdate: otherUpdates,
      ),
      originalUpdates: diff.originalUpdates.copyWith(
        toUpdate: originalUpdates,
      ),
    );
  }

  @override
  Future<void> saveChanges({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> dto,
  }) async {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}

typedef OnCheckUpdater<T extends HasId, TOther extends HasId>
    = UpdatableInstanceDiff<T, TOther> Function(
  UpdatableInstanceDiff<T, TOther> updatableDiff,
);

abstract class BasicProjectInstanceUpdater<T extends BasicProject,
    TOther extends BasicProjectModel> extends InstanceUpdater<T, TOther> {
  BasicProjectInstanceUpdater({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;
  UpdatableInstanceDiff<T, TOther> updateFolder(
    final UpdatableInstanceDiff<T, TOther> diff,
  ) {
    final original = diff.original;
    bool otherWasUpdated = diff.otherWasUpdated;
    bool originalWasUpdated = diff.originalWasUpdated;
    TOther other = diff.other;
    if (original.folder?.id != other.folderId) {
      InstanceUpdatePolicy folderUpdatePolicy =
          InstanceUpdatePolicy.useClientVersion;
      if (original.folder == null) {
        folderUpdatePolicy = InstanceUpdatePolicy.useServerVersion;
      }
      switch (folderUpdatePolicy) {
        case InstanceUpdatePolicy.useClientVersion:
          other = other.copyWith(
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
      other: other,
      originalWasUpdated: originalWasUpdated,
      otherWasUpdated: otherWasUpdated,
    );
  }

  @override
  Future<InstanceUpdaterDto<T, TOther>> compareDiffContent({
    required final InstanceUpdaterDto<T, TOther> diff,
    required final OnCheckUpdater<T, TOther> onCheck,
  }) async =>
      _compareDiffContent(
        diff: diff,
        updatables: [updateFolder, onCheck],
        onUpdated: (final original, final other) {
          other.copyWith(updatedAt: DateTime.now()) as TOther;
          original.updatedAt = other.updatedAt;

          return other;
        },
      );
}
