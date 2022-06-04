part of pack_settings;

MyAccountState useMyAccountState({
  required final AuthState authState,
}) =>
    use(
      LifeHook(
        debugLabel: 'MyAccountState',
        state: MyAccountState(authState: authState),
      ),
    );

class MyAccountState extends LifeState {
  MyAccountState({
    required this.authState,
  });
  final AuthState authState;

  Future<void> onDeleteAccount() async {
    final response = await AlertHelper.showYesNoWarning(
      title: 'Are you sure you want to delete your account?',
      message: 'Your account will be deleted permanently. \n'
          'All server data will be lost. \n'
          'All locally saved data will be accessable. \n'
          'You will lose not synchronized data.',
    );
    if (response == AlertButton.yesButton) {
      await authState.deleteUser();
    }
  }

  Future<void> onSingOut() async {
    await authState.signOut();
  }
}
