part of pack_auth;

AuthState useAuthState() => use(
      ContextfulLifeHook(
        debugLabel: 'AuthState',
        state: AuthState(),
      ),
    );

class AuthState extends SupabaseAuthLifeState {
  @override
  void onUnauthenticated() {}

  @override
  void onAuthenticated(final Session session) {}

  @override
  void onPasswordRecovery(final Session session) {}

  @override
  void onErrorAuthenticating(final String message) {
    context.showErrorSnackBar(message: message);
  }
}
