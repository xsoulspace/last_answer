part of pack_auth;

GlobalSignInScreenState useGlobalSignInScreenState({
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'GlobalSignInScreenState',
        state: GlobalSignInScreenState(
          authState: authState,
        ),
      ),
    );

class GlobalSignInScreenState extends ContextfulLifeState {
  GlobalSignInScreenState({
    required this.authState,
  });
  final AuthState authState;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  @override
  void dispose() {
    super.dispose();
    isLoading.dispose();
  }

  void onSignOut() {
    authState.signOut();
  }

  void onSignInByEmail() {
    showEmailSignInScreen(context: context);
  }

  void onSignUpByEmail() {
    showEmailSignUpScreen(context: context);
  }

  Future<void> signInWithDiscord() async {
    try {
      isLoading.value = true;
      await authState.signInWithDiscord();
    } finally {
      isLoading.value = false;
    }
  }
}
