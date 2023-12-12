import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';
import '../data_sources/remote/auth.dart';
import '../data_sources/remote/user.dart';

class UserRepository {
  UserRepository.provide(final BuildContext context)
      : _local = UserLocalDataSourceImpl(
          localDbDataSource: context.read(),
        ),
        _remote = UserRemoteDataSourceServerpodImpl(
          client: context.read<RemoteClient>() as RemoteClientServerpodImpl,
        ),
        _auth = AuthRemoteDataSourceServerpodImpl(
          client: context.read<RemoteClient>() as RemoteClientServerpodImpl,
        );
  final UserLocalDataSource _local;
  final UserRemoteDataSource _remote;
  final AuthRemoteDataSource _auth;
  Future<UserModel> getLocalUser() async => _local.getUser();
  Future<void> logout() async => _remote.logout();
  Future<void> putLocalUser({required final UserModel user}) async =>
      _local.putUser(user: user);
  Future<RemoteUserModel> getRemoteUser() => _remote.getUser();
  Future<void> completeRemoteLogin() => _auth.completeUserLogin();
  Future<void> putRemoteUser({required final RemoteUserModel user}) =>
      _remote.putUser(user: user);
  Future<void> deleteRemoteUser() => _remote.deleteUser();
}
