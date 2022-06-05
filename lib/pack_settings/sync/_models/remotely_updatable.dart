part of pack_settings;

// ignore: one_member_abstracts
abstract class RemotelyUpdatable<
    TMutable extends RemoteHiveObjectWithId<TImmutableOther>,
    TImmutableOther extends HasId> {
  Future<void> saveChanges({
    required final InstanceUpdaterDto<TMutable, TImmutableOther> dto,
  });
}
