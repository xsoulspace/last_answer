import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

class UserRepository implements UserLocalDataSource {
  UserRepository.provide(final BuildContext context)
      : _datasource = UserLocalDataSourceImpl(
          localDbDataSource: context.read(),
        );
  final UserLocalDataSource _datasource;
  @override
  Future<UserModel> getUser() async => _datasource.getUser();

  @override
  Future<void> putUser({required final UserModel user}) async =>
      _datasource.putUser(user: user);
}
