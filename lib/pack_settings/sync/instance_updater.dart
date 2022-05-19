part of pack_settings;

class InstanceUpdater<T extends DeletableWithId, TOther extends HasId> {
  InstanceUpdater({
    required this.list,
    this.policy = InstanceUpdatePolicy.useClientVersion,
  });
  final Iterable<T> list;
  final InstanceUpdatePolicy policy;

  @mustCallSuper
  Future<ModelUpdaterDiff<T, TOther>> updateByOther(
    final Iterable<TOther> otherList,
  ) async {
    final effectiveDiff = compareConsistency(otherList);
    return compareContent(diff: effectiveDiff);
  }

  /// Compares the elements of the lists, returns
  /// the new ones with deleted
  @mustCallSuper
  ModelUpdaterDiff<T, TOther> compareConsistency(
    final Iterable<TOther> otherList,
  ) {
    /// Generate other Map
    final otherMap = listWithIdToMap(otherList);

    final instancesToDeleteForOther = <InstanceId, T>{};
    final instancesToCreateForOther = <InstanceId, T>{};
    final instancesToCheckForOther = <InstanceId, InstanceDiff<T, TOther>>{};

    /// find differnces with [otherList] - online (server side)
    for (final el in list) {
      if (el.isToDelete) {
        instancesToDeleteForOther[el.id] = el;
        otherMap.remove(el.id);
      } else {
        final other = otherMap[el.id];
        final isExists = other != null;
        if (isExists) {
          instancesToCheckForOther[el.id] =
              InstanceDiff(original: el, other: other);
        } else {
          instancesToCreateForOther[el.id] = el;
        }
      }
    }

    final instancesToCreateForList = <InstanceId, TOther>{};

    /// find differnces with [list] - offline (client side)
    for (final el in otherMap.values) {
      final isNotExists = !instancesToCheckForOther.containsKey(el.id);
      if (isNotExists) {
        instancesToCreateForList[el.id] = el;
      }
    }

    return ModelUpdaterDiff(
      instancesToCheck: instancesToCheckForOther,
      otherInstancesToCreate: instancesToCreateForList,
      instancesToCreate: instancesToCreateForOther,
      instancesToDelete: instancesToDeleteForOther,
    );
  }

  Future<ModelUpdaterDiff<T, TOther>> compareContent({
    required final ModelUpdaterDiff<T, TOther> diff,
  }) async {
    // TODO(arenukvern): description
    throw UnimplementedError();
  }
}
