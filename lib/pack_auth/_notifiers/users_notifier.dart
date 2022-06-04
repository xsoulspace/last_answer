part of pack_auth;

UsersNotifier createUsersNotifier(
  final BuildContext context,
) =>
    UsersNotifier();

class UsersNotifier extends ChangeNotifier implements Loadable {
  final currentUser = ValueNotifier(UserModel.zero);
  final authenticated = ValueNotifier(false);
  @override
  Future<void> onLoad({required final BuildContext context}) {
    // TODO: implement onLoad
    throw UnimplementedError();
  }

  @override
  void dispose() {
    currentUser.dispose();
    authenticated.dispose();
    super.dispose();
  }
}
