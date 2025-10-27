import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../../core.dart';

final class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl({required this.localDbDataSource});
  final LocalDbI localDbDataSource;
  @override
  Future<UserModel> getUser() => localDbDataSource.getItem(
    key: SharedPreferencesKeys.user.name,
    fromJson: UserModel.fromJson,
    defaultValue: UserModel.empty,
  );

  @override
  Future<void> putUser({required final UserModel user}) async {
    await localDbDataSource.setItem(
      key: SharedPreferencesKeys.user.name,
      value: user,
      toJson: (final item) => item.toJson(),
    );
  }
}
