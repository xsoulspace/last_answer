import '../../models/models.dart';

abstract interface class UserApiService {
  Future<void> upsertUser(final UserModel model);
  Future<UserModel?> getUserById(final String id);
}
