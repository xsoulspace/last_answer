import '../../core.dart';

class UserRepository implements UserLocalDataSource {
  UserRepository({
    required this.userLocalDataSource,
  });
  final UserLocalDataSource userLocalDataSource;
  @override
  Future<UserModel> getUser() async => userLocalDataSource.getUser();

  @override
  Future<void> putUser({required final UserModel user}) async =>
      userLocalDataSource.putUser(user: user);
}
