part of pack_auth;

class AuthState extends SupabaseAuthLifeState {
  @override
  void onUnauthenticated() {
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (final route) => false);
    }
  }

  @override
  void onAuthenticated(final Session session) {
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (final route) => false);
    }
  }

  @override
  void onPasswordRecovery(final Session session) {}

  @override
  void onErrorAuthenticating(final String message) {
    context.showErrorSnackBar(message: message);
  }
}
