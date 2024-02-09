import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}

abstract interface class UserRemoteDataSource {
  Future<RemoteUserModel> getUser();
  Future<void> logout();
  Future<void> deleteUser();
}
