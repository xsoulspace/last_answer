import 'package:core_server_client/core_server_client.dart';
import 'package:shared_models/shared_models.dart';

import '../interfaces/interfaces.dart';
import 'serverpod_client.dart';

class UserRemoteDataSourceServerpodImpl implements UserRemoteDataSource {
  UserRemoteDataSourceServerpodImpl({
    required this.client,
  });
  final RemoteClientServerpodImpl client;

  Client get _client => client.client;

  @override
  Future<RemoteUserModel> getUser() async => _client.user.getUser();

  @override
  Future<void> putUser({required final RemoteUserModel user}) async =>
      _client.user.putUser(user);

  @override
  Future<void> deleteUser() => _client.user.deleteUser();
}
