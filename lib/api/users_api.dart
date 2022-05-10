part of api;

// TODO(arenukvern): write model
class UserModel {}

class UsersApi implements AbstractApi<UserModel> {
  UsersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;
}
