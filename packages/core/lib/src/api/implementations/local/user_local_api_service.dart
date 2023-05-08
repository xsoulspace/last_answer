import '../../../models/models.dart';
import '../../interfaces/interfaces.dart';
import 'local_api_service.dart';

/// The purpose of the service is to get | set information about
/// application wide user settings like locale, etc
class UserApiLocalServiceImpl implements UserApiLocalService {
  UserApiLocalServiceImpl({
    required this.localApiService,
  });
  final LocalApiService localApiService;
  static const _persistenceKey = 'user';
  @override
  Future<void> saveUser({
    required final UserModel user,
  }) async {
    await localApiService.setMap(_persistenceKey, user.toJson());
  }

  @override
  Future<UserModel> loadUser() async {
    final jsonMap = await localApiService.getMap(_persistenceKey);
    if (jsonMap.isEmpty) return UserModel.empty;
    try {
      return UserModel.fromJson(jsonMap);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // TODO(arenukvern): ignore this error but handle it in future
      return UserModel.empty;
    }
  }
}
