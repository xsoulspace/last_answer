part of pack_core;

abstract class Deletable {
  /// This property is used to mark instance
  /// as to be deleted in the server side.
  ///
  /// The principle is that once internet connection
  /// is established, the instance should be deleted.
  bool isToDelete = false;

  /// Call this method before the instance is to be deleted
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {}
}

abstract class HiveObjectWithId extends HiveObject implements Deletable, HasId {
}

abstract class RemoteHiveObjectWithId<TModel extends HasId> extends HiveObject
    implements Deletable, HasId, RemotelyAvailable<TModel> {}
