part of pack_auth;

AuthRequiredState useAuthRequiredState() => use(
      ContextfulLifeHook(
        debugLabel: 'AuthRequiredState',
        state: AuthRequiredState(),
      ),
    );

class AuthRequiredState extends SupabaseAuthRequiredLifeState {
  @override
  void onUnauthenticated() {
    /// Users will be sent back to the LoginPage if they sign out.
    if (mounted) {
      /// Users will be sent back to the LoginPage if they sign out.
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (final route) => false);
    }
  }
}
