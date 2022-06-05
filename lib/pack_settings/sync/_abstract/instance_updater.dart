part of pack_settings;

class InstanceUpdater<TMutable extends RemoteHiveObjectWithId<TImmutableOther>,
        TImmutableOther extends HasId, TNotifier extends MapState<TMutable>>
    implements RemotelyUpdatable<TMutable, TImmutableOther> {
  InstanceUpdater({
    required this.clientSyncService,
    required this.serverSyncService,
    this.defaultPolicy = InstanceUpdatePolicy.useClientVersion,
  });
  final InstanceUpdatePolicy defaultPolicy;
  final ClientInstancesSyncServiceI<TMutable, TImmutableOther, TNotifier>
      clientSyncService;
  final ServerInstancesSyncServiceI<TMutable, TImmutableOther>
      serverSyncService;

  Future<void> getAndUpdateByOther([final List<TImmutableOther>? other]) async {
    final list = await clientSyncService.getAll();
    final otherList = other ?? await serverSyncService.getAll();

    await updateByOther(otherList: otherList, list: list);
  }

  @mustCallSuper
  Future<void> updateByOther({
    required final Iterable<TImmutableOther> otherList,
    required final Iterable<TMutable> list,
  }) async {
    InstanceUpdaterDto<TMutable, TImmutableOther> dto =
        compareConsistency(otherList: otherList, list: list);

    dto = await compareContent(dto: dto);

    await saveChanges(dto: dto);
  }

  /// Compares the elements of the lists, returns
  /// the new ones with deleted
  @mustCallSuper
  InstanceUpdaterDto<TMutable, TImmutableOther> compareConsistency({
    required final Iterable<TImmutableOther> otherList,
    required final Iterable<TMutable> list,
  }) {
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
    await Future.wait([
      serverSyncService.applyUpdaterDto(dto: dto),
      clientSyncService.applyUpdaterDto(dto: dto),
    ]);
  }

  InstanceUpdatePolicy getPolicyForDiff(
    final UpdatableInstanceDiff<TMutable, TImmutableOther> diff,
  ) {
    // TODO(arenukvern): description
    throw UnimplementedError();
  }
}

typedef OnCheckUpdater<T extends HasId, TOther extends HasId>
    = UpdatableInstanceDiff<T, TOther> Function(
  UpdatableInstanceDiff<T, TOther> updatableDiff,
);

abstract class BasicProjectInstanceUpdater<
        TMutable extends BasicProject<TImmutableOther>,
        TImmutableOther extends BasicProjectModel,
        TNotifier extends MapState<TMutable>>
    extends InstanceUpdater<TMutable, TImmutableOther, TNotifier> {
  BasicProjectInstanceUpdater({
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;
  UpdatableInstanceDiff<TMutable, TImmutableOther> updateFolder(
    final UpdatableInstanceDiff<TMutable, TImmutableOther> diff,
  ) {
    final original = diff.original;
    bool otherWasUpdated = diff.otherWasUpdated;
    bool originalWasUpdated = diff.originalWasUpdated;
    TImmutableOther other = diff.other;
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
          ) as TImmutableOther;
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
  Future<InstanceUpdaterDto<TMutable, TImmutableOther>> compareDiffContent({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> diff,
    required final OnCheckUpdater<TMutable, TImmutableOther> onCheck,
  }) async =>
      _compareDiffContent(
        diff: diff,
        updatables: [updateFolder, onCheck],
        onUpdated: (final original, final other) {
          other.copyWith(updatedAt: DateTime.now()) as TImmutableOther;
          original.updatedAt = other.updatedAt;

          return other;
        },
      );

  @override
  InstanceUpdatePolicy getPolicyForDiff(
    final UpdatableInstanceDiff<TMutable, TImmutableOther> diff,
  ) {
    final useOriginalPolicy =
        diff.original.updatedAt.isAfter(diff.other.updatedAt);
    if (useOriginalPolicy) return InstanceUpdatePolicy.useClientVersion;

    return InstanceUpdatePolicy.useServerVersion;
  }
}
