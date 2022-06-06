part of pack_auth;

UsersNotifier createUsersNotifier(final BuildContext context) => UsersNotifier(
      supabaseClient: context.read(),
      usersApi: context.read(),
    );

class UsersNotifier extends ChangeNotifier implements Loadable {
  UsersNotifier({
    required this.usersApi,
    required this.supabaseClient,
  });
  final UsersApi usersApi;
  final SupabaseClient supabaseClient;
  final currentUser = ValueNotifier(UserModel.zero);
  final authenticated = ValueNotifier(false);
  @override
  Future<void> onLoad({required final BuildContext context}) async {
    await onAuthChange();
    authenticated.addListener(onAuthChange);
  }

  Future<void> onAuthChange() async {
    if (authenticated.value) {
      final id = supabaseClient.auth.currentUser?.id;
      if (id == null) {
        authenticated.value = false;
      } else {
        final user = await usersApi.getById(id);
        currentUser.value = user!;
      }
    } else {
      currentUser.value = UserModel.zero;
    }
  }

  @override
  void dispose() {
    currentUser.dispose();
    authenticated.dispose();
    super.dispose();
  }
}
