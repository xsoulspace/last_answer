part of pack_auth;

SignInScreenState useSignInScreenState({
  required final AuthState authState,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'SignInScreenState',
        state: SignInScreenState(
          authState: authState,
        ),
      ),
    );

class SignInScreenState extends ContextfulLifeState {
  SignInScreenState({
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

  Future<void> signInWithDiscord() async {
    try {
      isLoading.value = true;
      await authState.signInWithDiscord();
    } finally {
      isLoading.value = false;
    }
  }
}
