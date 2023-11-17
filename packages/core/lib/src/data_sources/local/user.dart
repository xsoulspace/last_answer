import '../../../core.dart';

final class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl({
    required this.localDbDataSource,
  });
  final LocalDbDataSource localDbDataSource;
  @override
  Future<UserModel> getUser() async =>
      localDbDataSource.getItem(
        key: SharedPreferencesKeys.user.name,
        convertFromJson: UserModel.fromJson,
      ) ??
      UserModel.empty;

  @override
  Future<void> putUser({required final UserModel user}) async {
    localDbDataSource.setItem(
      key: SharedPreferencesKeys.user.name,
      value: user,
      convertToJson: (final item) => item.toJson(),
    );
  }
}
