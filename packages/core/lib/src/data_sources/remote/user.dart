import '../../data_models/data_models.dart';
import '../interfaces/interfaces.dart';
import 'serverpod_client.dart';

class UserRemoteDataSourceServerpodImpl implements UserRemoteDataSource {
  UserRemoteDataSourceServerpodImpl({
    required this.client,
  });
  final RemoteClientServerpodImpl client;
  @override
  Future<RemoteUserModel> getUser() async => client.client.user.getUser();

  @override
  Future<void> putUser({required final RemoteUserModel user}) async {
    await client.client.user.putUser(user);
  }

  @override
  Future<void> deleteUser() => client.client.user.deleteUser();
}
