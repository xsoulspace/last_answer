import 'package:core_server_client/core_server_client.dart';

import '../interfaces/interfaces.dart';
import 'serverpod_client.dart';

class AuthRemoteDataSourceServerpodImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceServerpodImpl({
    required this.client,
  });
  final RemoteClientServerpodImpl client;

  Client get _client => client.client;

  @override
  Future<void> completeUserLogin() => _client.auth.completeSignIn();
}
