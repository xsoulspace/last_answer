import '../../api/api.dart';
import '../interfaces/interfaces.dart';

final class UserRepository
    extends Repository<UserApiRemoteService, UserApiLocalService> {
  UserRepository({required super.sources});
  void signIn() {
    // TODO(arenukvern): description
    throw UnimplementedError();
  }

  void signOut() {
    // TODO(arenukvern): description
    throw UnimplementedError();
  }
}
