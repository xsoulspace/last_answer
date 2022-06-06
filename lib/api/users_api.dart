part of api;

class UsersApi extends AbstractApiProps<UserModel>
    with AbstractApiMixin<UserModel>
    implements AbstractApi<UserModel> {
  UsersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;

  @override
  final fromJson = UserModel.fromJson;

  @override
  final modelToJson = UserModel.modelToJson;

  @override
  final tableName = 'users';
}
