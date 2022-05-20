part of pack_settings;

abstract class RemotelyUpdatable<T extends DeletableWithId,
    TOther extends HasId> {
  Future<void> saveChanges({
    required final InstanceUpdaterDto<T, TOther> diff,
  });
}
