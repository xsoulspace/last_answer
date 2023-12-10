import '../../../core.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}

abstract interface class UserRemoteDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}
