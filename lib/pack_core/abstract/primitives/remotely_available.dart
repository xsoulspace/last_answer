part of pack_core;

abstract class RemotelyAvailable<T extends HasId> {
  RemotelyAvailable._();
  T toModel({required final UserModel user});
}
