import '../../../core.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}

abstract interface class UserRemoteDataSource {
  Future<RemoteUserModel> getUser();
  Future<void> deleteUser();
  Future<void> putUser({required final RemoteUserModel user});
}
