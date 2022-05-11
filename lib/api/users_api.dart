part of api;

class UsersApi implements AbstractApi<UserModel> {
  UsersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;
}
