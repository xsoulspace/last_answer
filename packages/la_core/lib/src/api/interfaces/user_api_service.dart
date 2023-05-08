import '../../models/models.dart';

abstract interface class UserApiRemoteService {
  Future<void> upsertUser(final UserModel model);
  Future<UserModel?> getUserById(final String id);
}

abstract interface class UserApiLocalService {
  Future<void> saveUser({
    required final UserModel user,
  });
  Future<UserModel> loadUser();
}
