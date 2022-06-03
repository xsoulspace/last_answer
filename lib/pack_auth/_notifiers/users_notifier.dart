part of pack_auth;

class UsersNotifier extends ChangeNotifier implements Loadable {
  final currentUser = ValueNotifier(UserModel.zero);
  @override
  Future<void> onLoad({required final BuildContext context}) {
    // TODO: implement onLoad
    throw UnimplementedError();
  }

  @override
  void dispose() {
    currentUser.dispose();
    super.dispose();
  }
}
