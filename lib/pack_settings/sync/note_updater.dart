part of pack_settings;

class ModelUpdater<T extends DeletableWithId, TOther extends HasId> {
  ModelUpdater({
    required this.list,
  });
  final Iterable<T> list;

  @mustCallSuper
  ModelUpdaterDiff<T, TOther> updateByOther(
    final Iterable<TOther> otherList,
  ) {
    // TODO(arenukvern): add diff computation
    return const ModelUpdaterDiff();
  }

  /// Compares the elements of the lists, returns
  /// the new ones with deleted
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
}

class NoteUpdater extends ModelUpdater<NoteProject, NoteProjectModel> {
  NoteUpdater.of({
    required final super.list,
  });

  @override
  ModelUpdaterDiff<NoteProject, NoteProjectModel> updateByOther(
    final Iterable<NoteProjectModel> otherList,
  ) {
    final diff = super.updateByOther(otherList);
    // TODO(arenukvern): add diff update

    return const ModelUpdaterDiff();
  }

  void compareContent() {}
}
