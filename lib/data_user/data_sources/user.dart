import 'package:lastanswer/common_imports.dart';
import 'package:server_contracts/server_contracts.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}

abstract interface class UserRemoteDataSource {
  Future<RemoteUserModel> getUser();
  Future<void> logout();
  Future<void> deleteUser();
}
