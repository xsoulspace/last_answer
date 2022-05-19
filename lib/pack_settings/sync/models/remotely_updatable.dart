part of pack_settings;

abstract class RemotelyUpdatable {
  Future<void> saveChanges<T extends DeletableWithId, TOther extends HasId>({
    required final ModelUpdaterDiff<T, TOther> diff,
  });
}
