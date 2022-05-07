part of pack_auth;

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
