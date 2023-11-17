import '../../../core.dart';

abstract interface class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> putUser({required final UserModel user});
}
